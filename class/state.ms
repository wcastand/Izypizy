struct State(
  name,
  state,
  layer,
  -- GI
  GI = false,
  primary_engine = vr.gi_primary_type,
  primary_engine_preset = vr.gi_irradmap_preset,
  secondary_engine = vr.gi_secondary_type,
  -- Caustics
  caustics = false,
  caustics_search_dist = vr.caustics_searchDist,
  caustics_max_photons = vr.caustics_maxPhotons,
  caustics_max_density = vr.caustics_maxDensity,
  -- Image Samplers
  image_sampler = vr.imageSampler_type,
  -- Matte Shadow elements
  matte_shadow = #(),
  -- Light Select elements
  light_select = #(),
  --channel array
  render_element_state = #(
    false, --MultiMatteElement
    false, --VRayAlpha
    false, --VRayAtmosphere
    false, --VRayBackground
    false, --VRayCaustics
    false, --VRayDiffuseFilter
    false, --VRayGlobalIllumination
    false, --VRayLighting
    false, --VRayMatteShadow
    false, --VRayMtlID
    false, --VRayMtlSelect
    false, --VRayNormals
    false, --VRayObjectID
    false, --VRayRawGlobalIllumination
    false, --VRayRawLighting
    false, --VRayRawRefraction
    false, --VRayRawShadow
    false, --VRayRawTotalLighting
    false, --VRayReflectionFilter
    false, --VRayReflection
    false, --VRayRefractionFilter
    false, --VRayRefraction
    false, --VRayRenderID
    false, --VRaySelfIllumination
    false, --VRayShadows
    false, --VRaySpecular
    false, --VRayTotalLighting
    false, --VRayUnclampedColor
    false, --VRayRawReflection
    false, --VRayWireColor
    false, --VRayVelocity
    false  --VRayZDepth
    ),
  render_element = #(
    MultiMatteElement,
    VRayAlpha,
    VRayAtmosphere,
    VRayBackground,
    VRayCaustics,
    VRayDiffuseFilter,
    VRayGlobalIllumination,
    VRayLighting,
    VRayMatteShadow,
    VRayMtlID,
    VRayMtlSelect,
    VRayNormals,
    VRayObjectID,
    VRayRawGlobalIllumination,
    VRayRawLighting,
    VRayRawRefraction,
    VRayRawShadow,
    VRayRawTotalLighting,
    VRayReflectionFilter,
    VRayReflection,
    VRayRefractionFilter,
    VRayRefraction,
    VRayRenderID,
    VRaySelfIllumination,
    VRayShadows,
    VRaySpecular,
    VRayTotalLighting,
    VRayUnclampedColor,
    VRayRawReflection,
    VRayWireColor,
    VRayVelocity,
    VRayZDepth
    ),
  --Light Select
  fn filterLight obj                     = ( isKindOf obj Light; ),
  fn addLightSelectPasse                 = (
    temp_render = VRayLightSelect elementname:("light_select_" + light_select.count as string);
    lights = selectByName title:"Select Lights" buttonText:"Add" filter:filterLight showHidden:true single:false;
    if lights != undefined then (
      temp_render.lights = lights;
      re.AddRenderElement temp_render;
      append light_select temp_render;
      LightList.items = append LightList.items temp_render.elementname;
      )
    ),
  fn deleteLightSelectPasse              = (
    index = LightList.selection;
    for i = 1 to light_select.count do ( if LightList.selected == light_select[i].elementname then (
      re.RemoveRenderElement light_select[i];
      deleteItem light_select i;
      )
    )
    temp = LightList.items;
    deleteItem temp index;
    LightList.items = temp;
    ),
  fn renameLightElement item             = (
    renamer = dotNetObject "MaxCustomControls.RenameInstanceDialog" LightList.items[item]
    DialogResult = renamer.Showmodal();
    if dotnet.compareenums renamer.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)
    then (
      new_name = renamer.InstanceName;
      for n in light_select do ( if n.elementname == LightList.items[item] then n.elementname = new_name; )
      --delete old name
      temp = LightList.items;
      deleteItem temp item;
      LightList.items = temp;
      --add new one
      LightList.items = append LightList.items new_name;
      );
    ),
  fn updateLightSelectPasse              = (
    LightList.items = #();
    for n in light_select do (
      re.AddRenderElement n;
      LightList.items = append LightList.items n.elementname;
      )
    ),
  --Matte Object
  fn filterMatte obj                     = (
    local theNodes = undefined;
    local return_value = true;
    layer.nodes &theNodes;
    for i= 1 to theNodes.count do (
      if obj == theNodes[i]
      then return_value = false;
      );
    return (isKindOf obj GeometryClass and not isKindOf obj TargetObject and return_value);
    ),
  fn pickMatteObjects                    = (
    matte_shadow = selectByName title:"Select Matte Objects" buttonText:"Add" filter:filterMatte showHidden:true single:false;
    current_state.state.BeginRecording();
    if matte_shadow != undefined
    then (
      for n in matte_shadow do (
        MatteList.items = append MatteList.items n.name;
        unhide n;
        setMatteShadow n;
        )
      )
    current_state.state.EndRecording();
    ),
  fn deleteMatteObject item              = (
    current_state.state.BeginRecording();
    for i = 1 to matte_shadow.count do (
      obj = getNodeByName MatteList.items[item];
      if matte_shadow[i] == obj
      then (
        hide obj;
        deleteItem matte_shadow i;
        )
      );
    temp = MatteList.items;
    deleteItem temp item;
    MatteList.items = temp;
    current_state.state.EndRecording();
    ),
  fn updateMatteList                     = (
    MatteList.items = #();
    for n in matte_shadow do (
      MatteList.items = append MatteList.items n.name;
      )
    ),
  --GI
  fn updateGI new_val                    = ( vr.gi_on = GI = new_val; ),
  fn updatePrimaryEngine new_val         = ( vr.gi_primary_type  = primary_engine = new_val - 1; ),
  fn updatePrimaryEnginePreset new_val   = ( vr.gi_irradmap_preset  = primary_engine_preset = new_val; ),
  fn updateSecondaryEngine new_val       = ( vr.gi_secondary_type  = secondary_engine = new_val - 1; ),
  --Caustics
  fn updateCaustics new_val              = ( vr.caustics_on  = caustics = new_val; ),
  fn updateSearchDist new_val            = ( vr.caustics_searchDist  = caustics_search_dist = new_val; ),
  fn updateMaxPhotons new_val            = ( vr.caustics_maxPhotons  = caustics_max_photons = new_val; ),
  fn updateCausticsMaxDensity new_val    = ( vr.caustics_maxDens  = caustics_max_density = new_val; ),
  --Image Samplers
  fn updateImageSampler new_val          = ( vr.imageSampler_type  = image_sampler = new_val - 1; ),
  -- render_element manage
  -- ZDepth render_element
  fn getZElement                   = ( return render_element[render_element.count]; ),
  fn updateZUI                     = (
    passesController.Z.checked = render_element_state[render_element.count];
    if passesController.Z.checked
    then (
      z = getZElement();
      passesController.z_min.value = z.zdepth_min;
      passesController.z_max.value = z.zdepth_max;
      )
    else (
      passesController.z_min.value = units.decodeValue "0.0cm";
      passesController.z_max.value = units.decodeValue "500.0cm";
      )
    ),
  fn updateZMin new_val            = ( z = getZElement(); z.zdepth_min = new_val; ),
  fn updateZMax new_val            = ( z = getZElement(); z.zdepth_max = new_val; ),
  fn updateZDepth new_val          = (
   z = getZElement();
   if new_val
   then re.AddRenderElement z;
   else re.RemoveRenderElement z;
   i = findItem render_element z;
   render_element_state[i] = new_val;
   ),
  -- Velocity render_element
  fn getVelocityElement            = ( return render_element[render_element.count - 1]; ),
  fn updateVelocityUI              = (
    passesController.velocity.checked = render_element_state[render_element.count - 1];
    if passesController.velocity.checked
    then (
      v = getVelocityElement();
      passesController.max_velocity.value = v.max_velocity;
      passesController.ignore_z.checked = v.ignore_z_direction;
      )
    else (
      passesController.max_velocity.value = 1.0;
      passesController.ignore_z.checked = false;
      )
    ),
  fn updateMaxDensity new_val      = ( v = getVelocityElement(); v.max_velocity = new_val; ),
  fn updateIgnoreZ new_val         = ( v = getVelocityElement(); v.ignore_z_direction = new_val; ),
  fn updateVelocity new_val        = (
   v = getVelocityElement();
   if new_val
   then re.AddRenderElement v;
   else re.RemoveRenderElement v;
   i = findItem render_element v;
   render_element_state[i] = new_val;
   ),
  -- general render_element
  fn updateChannel new_val index   = (
   channel = render_element[index];
   if new_val
   then re.AddRenderElement channel;
   else re.RemoveRenderElement channel;
   render_element_state[index] = new_val;
   ),
  fn updateChannelUI = (
    passesController.MultiMatteElement.checked = render_element_state[1];
    passesController.VRayAlph.checked = render_element_state[2];
    passesController.VRayAtmosphere.checked = render_element_state[3];
    passesController.VRayBackground.checked = render_element_state[4];
    passesController.VRayCaustics.checked = render_element_state[5];
    passesController.VRayDiffuseFilter.checked = render_element_state[6];
    passesController.VRayGlobalIllumination.checked = render_element_state[7];
    passesController.VRayLighting.checked = render_element_state[8];
    passesController.VRayMatteShadow.checked = render_element_state[9];
    passesController.VRayMtlID.checked = render_element_state[10];
    passesController.VRayMtlSelect.checked = render_element_state[11];
    passesController.VRayNormals.checked = render_element_state[12];
    passesController.VRayObjectID.checked = render_element_state[13];
    passesController.VRayRawGlobalIllumination.checked = render_element_state[14];
    passesController.VRayRawLighting.checked = render_element_state[15];
    passesController.VRayRawRefraction.checked = render_element_state[16];
    passesController.VRayRawShadow.checked = render_element_state[17];
    passesController.VRayRawTotalLighting.checked = render_element_state[18];
    passesController.VRayReflectionFilter.checked = render_element_state[19];
    passesController.VRayReflection.checked = render_element_state[20];
    passesController.VRayRefractionFilter.checked = render_element_state[21];
    passesController.VRayRefraction.checked = render_element_state[22];
    passesController.VRayRenderID.checked = render_element_state[23];
    passesController.VRaySelfIllumination.checked = render_element_state[24];
    passesController.VRayShadows.checked = render_element_state[25];
    passesController.VRaySpecular.checked = render_element_state[26];
    passesController.VRayTotalLighting.checked = render_element_state[27];
    passesController.VRayUnclampedColor.checked = render_element_state[28];
    passesController.VRayRawReflection.checked = render_element_state[29];
    passesController.VRayWireColor.checked = render_element_state[30];
    ),
fn createRenderElement = (
  for n in render_element do (
    i = findItem render_element n
    render_element[i] = (n elementname:(n as string));
    );
  ),
fn updateRenderElement = (
  re.RemoveAllRenderElements();
  for n in render_element do (
    i = findItem render_element n;
    if render_element_state[i] then ( re.AddRenderElement n; )
    );
  ),
fn updateUI = (
  --GI
  updateGI GI; passesController.GI.checked = GI;
  updatePrimaryEngine (primary_engine + 1); passesController.primary_engine.selection = primary_engine + 1;
  updateSecondaryEngine (secondary_engine + 1); passesController.secondary_engine.selection = secondary_engine + 1;
  updatePrimaryEnginePreset (primary_engine_preset); passesController.primary_engine_preset.selection = primary_engine_preset;
  --Caustics
  updateCaustics caustics; passesController.caustics.checked = caustics;
  updateSearchDist caustics_search_dist; passesController.caustics_search_dist.value = caustics_search_dist;
  updateMaxPhotons caustics_max_photons; passesController.caustics_max_photons.value = caustics_max_photons;
  updateCausticsMaxDensity caustics_max_density; passesController.caustics_max_density.value = caustics_max_density;
  --Image Samplers
  updateImageSampler (image_sampler + 1); passesController.image_sampler.selection = image_sampler + 1;
  --Render Element
  --Velocity
  updateVelocityUI();
  --ZDepth
  updateZUI();
  --channels
  updateChannelUI();
  )
);
