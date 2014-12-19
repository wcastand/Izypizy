struct GeneralCtrl(
  save_dir,
  directory_set,
  camera_set,
  time_output,
  range_start,
  range_end,
  size_output_width,
  size_output_height,
  ao_state,
  ao_element,
  fn updateSettings        = (
    passesController.time_output.selection = time_output;
    passesController.range_start.value = range_start;
    passesController.range_end.value = range_end;
    passesController.size_output_width.value = size_output_width;
    passesController.size_output_height.value = size_output_height;
    ),
  fn init = (
    save_dir = "";
    directory_set      = false;
    camera_set         = false;
    time_output        = rendTimeType;
    range_start        = rendStart;
    range_end          = rendEnd;
    size_output_width  = renderWidth;
    size_output_height = renderHeight;
    dirt = VRayDirt();
    ao_element = VRayMtl name: "AO" texmap_diffuse: dirt texmap_diffuse_on: true;
    ao_state = false;
    updateSettings();
    ),
  fn applyToAllState param = (
    if current_state != undefined then state_saved = current_state;
    for i = 1 to states.count do (
      current_state            = states[i];
      masterState.CurrentState = #(current_state.state);

      current_state.state.BeginRecording();
      case param of (
        "width"      : renderWidth  = size_output_width;
        "height"     : renderHeight = size_output_height;

        "timeType"   : rendTimeType = rendTimeType;
        "startRange" : rendStart    = range_start;
        "endRange"   : rendEnd      = range_end;
        "all"        : (
          renderWidth       = size_output_width;
          renderHeight      = size_output_height;
          rendTimeType      = rendTimeType;
          rendStart         = range_start;
          rendEnd           = range_end;
          );
        )
      current_state.state.EndRecording();
      )
    if current_state != undefined then (
      current_state            = state_saved;
      masterState.CurrentState = #(current_state.state);
      )
    ),
fn updateOutputWidth new_val  = ( renderWidth  = size_output_width  = new_val; applyToAllState("width"); ),
fn updateOutputHeight new_val = ( renderHeight = size_output_height = new_val; applyToAllState("height"); ),
fn updateTimeOutput new_val   = ( rendTimeType = rendTimeType       = new_val; applyToAllState("timeType"); ),
fn updateRangeStart new_val   = ( rendStart    = range_start        = new_val; applyToAllState("startRange"); ),
fn updateRangeEnd new_val     = ( rendEnd      = range_end          = new_val; applyToAllState("endRange"); ),
-- AO render_element
fn updateAOUI                 = (
  passesController.AO.checked = ao_state;
  if passesController.AO.checked
  then (
    passesController.ao_occluded_color.color = ao_element.texmap_diffuse.occluded_color;
    passesController.ao_unoccluded_color.color = ao_element.texmap_diffuse.unoccluded_color;
    passesController.ao_radius.value = ao_element.texmap_diffuse.radius;
    passesController.ao_falloff.value = ao_element.texmap_diffuse.falloff;
    )
  else (
    passesController.ao_occluded_color.color = color 0 0 0;
    passesController.ao_unoccluded_color.color = color 255 255 255;
    passesController.ao_radius.value = units.decodeValue "25.4cm";
    passesController.ao_falloff.value = 0.0;
    )
  ),
fn updateOccludedColor new_val   = ( ao_element.texmap_diffuse.occluded_color = new_val; ),
fn updateUnoccludedColor new_val = ( ao_element.texmap_diffuse.unoccluded_color = new_val; ),
fn updateRadius new_val          = ( ao_element.texmap_diffuse.radius = new_val; ),
fn updateFalloff new_val         = ( ao_element.texmap_diffuse.falloff = new_val; ),
fn updateAO new_val              = (
  masterState.CurrentState = #(backup.state);
  if new_val
  then ( masterState.AddChild ao.state false; append states ao; )
  else ( masterState.RemoveChild ao.state; i = findItem states ao; deleteItem states i;)
  ao_state = new_val;
  masterState.CurrentState = #(current_state.state);
  ),
-- get camera
fn filterCamera obj = ( return isKindOf obj Camera; ),
fn pickCamera      = (
  save_camera = selectByName title:"Select Camera" buttonText:"Select" filter:filterCamera showHidden:true single:true;
  if save_camera != undefined
  then (
    camera_set = true;
    passesController.render_all.enabled = directory_set and camera_set;
    )
  ),
-- render save and all that sutff wesh
fn getSaveDir = (
  save_dir = getSavePath caption:"Select Destination Folder" initialDir:#images;
  if save_dir != undefined
  then (
    directory_set = true;
    passesController.render_all.enabled = directory_set and camera_set;
    )
  ),
fn saveAllPasses = (
  for i = 1 to states.count do (
    makeDir (save_dir as string + "\\" + states[i].name as string) all:true;
    current_state            = states[i];
    masterState.CurrentState = #(current_state.state);

    current_state.state.BeginRecording();
    vr.output_saveFile =  false;
    vr.output_saveRawFile =  true;
    vr.output_rawFileName = save_dir + "\\" + current_state.name + "\\" + "render.exr";
    current_state.state.EndRecording();

    selectPasse states[i].name;
    states[i].state.Render #(states[i].state) camera:save_camera quiet:true missingExtFilesAction:#logmsg unsupportedRenderEffectAction:#logmsg;
    )
  );
);
