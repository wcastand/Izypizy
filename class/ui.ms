rollout passesController "Izipizy" (
  --Base
  groupBox base_group "Base" pos:[10,10] width:330 height:140;
  button generate "Generate layers" width:100 pos:[20,30];
  button reset "Reset layers" width:100 pos:[20,60];
  button suppress "Suppress layers" width:100 pos:[20,90];
  listbox listePasses height:8 width:200 pos:[130,30];
  on generate pressed do generatePasse();
  on reset pressed do resetPasse();
  on suppress pressed do suppressPasse();
  on listePasses selected i do selectPasse(listePasses.items[i]);

  -- General Settings
  groupBox general_settings_group "General Settings" pos:[350,10] width:400 height:170;
  groupBox time_output_group "Time Output" pos:[360,30] width:110 height:140;
  dropdownlist time_output "" items:#("Single", "Active Time Segment", "Range") width:90 pos:[370,50] align:#left;
  -- range
  label range_start_label "Start:" pos:[370,80] align:#left;
  spinner range_start "" range:[0,10000,rendStart] type:#integer enabled:false pos:[370,100] width:90 align:#left;
  label range_end_label "To:" pos:[370,120] align:#left;
  spinner range_end "" range:[0,100,rendEnd] type:#integer enabled:false pos:[370,140] width:90 align:#left;
  on range_start changed new_val do general_ctrl.updateRangeStart new_val;
  on range_end changed new_val do general_ctrl.updateRangeEnd new_val;
  on time_output selected index do(
    general_ctrl.updateTimeOutput index;
    if index == 3
    then (
      range_start.enabled = true;
      range_end.enabled = true;
      range_start_label.enabled = true;
      range_end_label.enabled = true;
      )
    else(
      range_start_label.enabled = false;
      range_end_label.enabled = false;
      )
    );
  --size output
  groupBox size_output_group "Size output" pos:[480,30] width:110 height:140;
  label size_output_width_label "Width:" pos:[490,50] align:#left;
  spinner size_output_width "" range:[0,10000,renderWidth] type:#integer pos:[485,70] width:95 align:#left;
  label size_output_height_label "Height:" pos:[490,90] align:#left;
  spinner size_output_height "" range:[0,10000,renderHeight] type:#integer pos:[485,110] width:95 align:#left;
  on size_output_width changed new_val do general_ctrl.updateOutputWidth new_val;
  on size_output_height changed new_val do general_ctrl.updateOutputHeight new_val;
  -- AO
  groupBox ao_group "Activate AO" pos:[600,30] width:140 height:140;
  checkbox AO "Activate AO" checked:false tooltip:"Activate Ambient occlusion channel" pos:[605,30];
  label ao_occluded_color_label "Occluded color:" pos:[610,53] align:#left;
  colorpicker ao_occluded_color "" enabled: false color:[0,0,0] modal:false width:40 align:#left pos:[695,50];
  label ao_unoccluded_color_label "Unoccluded color:" pos:[610,83] align:#left;
  colorpicker ao_unoccluded_color "" enabled: false color:[255,255,255] modal:false width:40 align:#left pos:[695,80];
  spinner ao_radius "Radius:" enabled: false range:[0,10000,15] type:#worldunits width:90 align:#left pos:[610,110];
  spinner ao_falloff "Falloff:" enabled: false range:[0,100,1] width:90 align:#left pos:[610,140];
  on AO changed new_val do (
    ao_occluded_color.enabled = new_val;
    ao_unoccluded_color.enabled = new_val;
    ao_occluded_color_label.enabled = new_val;
    ao_unoccluded_color_label.enabled = new_val;
    ao_radius.enabled = new_val;
    ao_falloff.enabled = new_val;
    general_ctrl.updateAO new_val;
    );
  on ao_occluded_color changed new_val do general_ctrl.updateOccludedColor new_val;
  on ao_unoccluded_color changed new_val do general_ctrl.updateUnoccludedColor new_val;
  on ao_radius changed new_val do general_ctrl.updateRadius new_val;
  on ao_falloff changed new_val do general_ctrl.updateFalloff new_val;

  -- Image Samplers
  groupBox img_sampler_group "Image sampler" pos:[760,10] width:260 height:50;
  dropdownlist image_sampler "" items:#("Fixed", "Adaptative", "Adaptative subdivision", "Progressive") align:#left width:115 pos:[770,30];
  button advanced_image_sampler "Advanced settings" width:115 height: 20 pos:[895,30] enabled: false;
  on image_sampler selected new_val do current_state.updateImageSampler new_val;
  on advanced_image_sampler pressed do renderSceneDialog.open();
  -- Caustics
  groupBox caustics_group "Activate Caustics" pos:[760,70] width:260 height:110;
  checkbox caustics "Activate Caustics" checked:false tooltip:"Activate V-Ray Caustics" pos:[765,70];
  label search_dist_label "Search Dist:" width:100 pos:[770,90] align:#left;
  spinner caustics_search_dist "" range:[0,10000,vr.caustics_searchDist] type:#worldunits width:100 pos:[765,110] align:#left;
  label max_photons_label "Max Photons:" width:100 pos:[770,130] align:#left;
  spinner caustics_max_photons "" range:[0,10000,vr.caustics_maxPhotons] type:#integer width:100 pos:[765,150] align:#left;
  label max_density_label "Max Density:" width:100 pos:[890,90] align:#left;
  spinner caustics_max_density "" range:[0,10000,vr.caustics_maxDensity] type:#worldunits width:100 pos:[885,110] align:#left;
  on caustics changed new_val do (
    caustics_search_dist.enabled = new_val;
    caustics_max_photons.enabled = new_val;
    caustics_max_density.enabled = new_val;
    search_dist_label.enabled = new_val;
    max_photons_label.enabled = new_val;
    max_density_label.enabled = new_val;
    current_state.updateCaustics new_val;
    );
  on caustics_search_dist changed new_val do current_state.updateSearchDist new_val;
  on caustics_max_photons changed new_val do current_state.updateMaxPhotons new_val;
  on caustics_max_density changed new_val do current_state.updateCausticsMaxDensity new_val;

  -- GI
  groupBox gi_group "Activate GI" pos:[350,185] width:270 height:110;
  checkbox GI "Activate GI" checked:vr.gi_on tooltip:"Activate V-Ray Global Illumination" pos:[355,185];
  dropdownlist primary_engine "Primary Engine" items:#("Irradiance map", "Photon map", "Brute force", "Light cache") width:120 pos:[360,205];
  dropdownlist primary_engine_preset "Primary Presets" items:#("Very low", "Low", "Medium", "Medium - anim", "High", "High - anim", "Very High") width:120 pos:[360,245];
  dropdownlist secondary_engine "Secondary Engine" items:#("None", "Photon map", "Brute Force", "Light Cache") width:120 pos:[490,205];
  button advanced_gi "Advanced settings" width:120 height:20 pos:[490,263] enabled: false;
  on GI changed new_val do (
    advanced_gi.enabled = new_val;
    primary_engine.enabled = new_val;
    secondary_engine.enabled = new_val;
    primary_engine_preset.enabled = new_val;
    current_state.updateGI new_val;
    );
  on primary_engine selected new_val do (
    current_state.updatePrimaryEngine new_val;
    if new_val == 1
    then primary_engine_preset.enabled = true;
    else primary_engine_preset.enabled = false;
    )
  on primary_engine_preset selected new_val do current_state.updatePrimaryEnginePreset new_val;
  on secondary_engine selected new_val do ( current_state.updateSecondaryEngine new_val; );
  on advanced_gi pressed do renderSceneDialog.open();

  -- ZDepth
  groupBox z_group "ZDepth" pos:[630,185] width:120 height:110;
  checkbox Z "Activate ZDepth" checked:false tooltip:"Activate ZDepth channel" pos:[635,185];
  label z_min_label "ZMin:" width:100 pos:[640,205] align:#left;
  spinner z_min "" range:[0,100,0] type:#worldunits align:#left width:100 pos:[635,225];
  label z_max_label "ZMax:" width:100 pos:[640,245] align:#left;
  spinner z_max "" range:[0,100000,1270] type:#worldunits align:#left width:100 pos:[635,265];
  on Z changed new_val do (
    z_min.enabled = new_val;
    z_max.enabled = new_val;
    z_min_label.enabled = new_val;
    z_max_label.enabled = new_val;
    current_state.updateZDepth new_val;
    );
  on z_min changed new_val do current_state.updateZMin new_val;
  on z_max changed new_val do current_state.updateZMax new_val;
  -- Velocity
  groupBox velocity_group "Velocity" pos:[760,185] width:120 height:110;
  checkbox velocity "Activate Velocity" checked:false tooltip:"Activate Velocity channel" pos:[765,185];
  label max_velocity_label "Max Velocity:" width:100 pos:[770,205] align:#left;
  spinner max_velocity "" range:[0,100,0] type:#float align:#left width:100 pos:[770,225];
  label ignore_z_label "Ignore Z direction:" width:100 pos:[770,245] align:#left;
  checkbox ignore_z "" checked:false pos:[770,265];
  on velocity changed new_val do (
    max_velocity_label.enabled = new_val;
    max_velocity.enabled = new_val;
    ignore_z_label.enabled = new_val;
    ignore_z.enabled = new_val;
    current_state.updateVelocity new_val;
    );
  on max_velocity changed new_val do current_state.updateMaxDensity new_val;
  on ignore_z changed new_val do current_state.updateIgnoreZ new_val;

  --C'est la zone 51!!!
  groupBox zone_51 "C'est la zone 51 !!!" pos:[890,185] width:130 height:110;
  bitmap bmp_zone51 fileName:"alien.bmp" pos:[910, 200] width: 90 height: 90;

  --Light Select Passe
  groupBox light_select_group "Light Select" pos:[350,300] width:160 height:190;
  button add_light_select "Add Light Select" width:140 height:20 pos:[360,320] enabled: false;
  listbox liste_light_select height:9 width:140 pos:[360,350] enabled: false;
  on add_light_select pressed do current_state.addLightSelectPasse();

  --Mask RGB Passe
  groupBox mask_group "RGB Mask" pos:[520,300] width:160 height:190;


  --Matte Shadow
  groupBox matte_shadow_group "Matte Shadow" pos:[690,300] width:190 height:190;
  button pick_matte_objects "Pick Objects" width:170 height:20 pos:[700,320] enabled: false;
  multiListBox liste_matte_objects height:9 width:170 pos:[700,350] enbaled: false;
  on pick_matte_objects pressed do current_state.pickMatteObjects();
  on liste_matte_objects doubleclicked item do current_state.deleteMatteObject item;

  --Render
  groupBox final_group "Render Option" pos:[890,300] width:130 height:190;
  button set_camera "Choose camera" width:100 height:30 pos:[905,330];
  button set_path "Choose directory" width:100 height:30 pos:[905,390];
  button render_all "Render passes" width:100 height:30 pos:[905,450];
  on set_camera pressed do general_ctrl.pickCamera();
  on set_path pressed do general_ctrl.getSaveDir();
  on render_all pressed do general_ctrl.saveAllPasses();

  -- Channels
  groupBox channel_group "Channels" pos:[10,155] width:330 height:335;
  checkbox MultiMatteElement "MultiMatteElement" checked:false tooltip:"Activate MultiMatteElement channel" align:#left pos:[20,170];
  checkbox VRayAlph "VRayAlph" checked:false tooltip:"Activate VRayAlph channel" align:#left pos:[20,190];
  checkbox VRayAtmosphere "VRayAtmosphere" checked:false tooltip:"Activate VRayAtmosphere channel" align:#left pos:[20,210];
  checkbox VRayBackground "VRayBackground" checked:false tooltip:"Activate VRayBackground channel" align:#left pos:[20,230];
  checkbox VRayCaustics "VRayCaustics" checked:false tooltip:"Activate VRayCaustics channel" align:#left pos:[20,250];
  checkbox VRayDiffuseFilter "VRayDiffuseFilter" checked:false tooltip:"Activate VRayDiffuseFilter channel" align:#left pos:[20,270];
  checkbox VRayGlobalIllumination "VRayGlobalIllumination" checked:false tooltip:"Activate VRayGlobalIllumination channel" align:#left pos:[20,290];
  checkbox VRayLighting "VRayLighting" checked:false tooltip:"Activate VRayLighting channel" align:#left pos:[20,310];
  checkbox VRayMatteShadow "VRayMatteShadow" checked:false tooltip:"Activate VRayMatteShadow channel" align:#left pos:[20,330];
  checkbox VRayMtlID "VRayMtlID" checked:false tooltip:"Activate VRayMtlID channel" align:#left pos:[20,350];
  checkbox VRayMtlSelect "VRayMtlSelect" checked:false tooltip:"Activate VRayMtlSelect channel" align:#left pos:[20,370];
  checkbox VRayNormals "VRayNormals" checked:false tooltip:"Activate VRayNormals channel" align:#left pos:[20,390];
  checkbox VRayObjectID "VRayObjectID" checked:false tooltip:"Activate VRayObjectID channel" align:#left pos:[20,410];
  checkbox VRayRawGlobalIllumination "VRayRawGlobalIllumination" checked:false tooltip:"Activate VRayRawGlobalIllumination channel" align:#left pos:[20,430];
  checkbox VRayRawLighting "VRayRawLighting" checked:false tooltip:"Activate VRayRawLighting channel" align:#left pos:[20,450];
  checkbox VRayRawRefraction "VRayRawRefraction" checked:false tooltip:"Activate VRayRawRefraction channel" align:#right pos:[200,170];
  checkbox VRayRawShadow "VRayRawShadow" checked:false tooltip:"Activate VRayRawShadow channel" align:#right pos:[200,190];
  checkbox VRayRawTotalLighting "VRayRawTotalLighting" checked:false tooltip:"Activate VRayRawTotalLighting channel" align:#right pos:[200,210];
  checkbox VRayReflectionFilter "VRayReflectionFilter" checked:false tooltip:"Activate VRayReflectionFilter channel" align:#right pos:[200,230];
  checkbox VRayReflection "VRayReflection" checked:false tooltip:"Activate VRayReflection channel" align:#right pos:[200,250];
  checkbox VRayRefractionFilter "VRayRefractionFilter" checked:false tooltip:"Activate VRayRefractionFilter channel" align:#right pos:[200,270];
  checkbox VRayRefraction "VRayRefraction" checked:false tooltip:"Activate VRayRefraction channel" align:#right pos:[200,290];
  checkbox VRayRenderID "VRayRenderID" checked:false tooltip:"Activate VRayRenderID channel" align:#right pos:[200,310];
  checkbox VRaySelfIllumination "VRaySelfIllumination" checked:false tooltip:"Activate VRaySelfIllumination channel" align:#right pos:[200,330];
  checkbox VRayShadows "VRayShadows" checked:false tooltip:"Activate VRayShadows channel" align:#right pos:[200,350];
  checkbox VRaySpecular "VRaySpecular" checked:false tooltip:"Activate VRaySpecular channel" align:#right pos:[200,370];
  checkbox VRayTotalLighting "VRayTotalLighting" checked:false tooltip:"Activate VRayTotalLighting channel" align:#right pos:[200,390];
  checkbox VRayUnclampedColor "VRayUnclampedColor" checked:false tooltip:"Activate VRayUnclampedColor channel" align:#right pos:[200,410];
  checkbox VRayRawReflection "VRayRawReflection" checked:false tooltip:"Activate VRayRawReflection channel" align:#left pos:[200,430];
  checkbox VRayWireColor "VRayWireColor" checked:false tooltip:"Activate VRayWireColor channel" align:#right pos:[200,450];
  on MultiMatteElement changed new_val do current_state.updateChannel new_val 1;
  on VRayAlph changed new_val do current_state.updateChannel new_val 2;
  on VRayAtmosphere changed new_val do current_state.updateChannel new_val 3;
  on VRayBackground changed new_val do current_state.updateChannel new_val 4;
  on VRayCaustics changed new_val do current_state.updateChannel new_val 5;
  on VRayDiffuseFilter changed new_val do current_state.updateChannel new_val 6;
  on VRayGlobalIllumination changed new_val do current_state.updateChannel new_val 7;
  on VRayLighting changed new_val do current_state.updateChannel new_val 8;
  on VRayMatteShadow changed new_val do current_state.updateChannel new_val 9;
  on VRayMtlID changed new_val do current_state.updateChannel new_val 10;
  on VRayMtlSelect changed new_val do current_state.updateChannel new_val 11;
  on VRayNormals changed new_val do current_state.updateChannel new_val 12;
  on VRayObjectID changed new_val do current_state.updateChannel new_val 13;
  on VRayRawGlobalIllumination changed new_val do current_state.updateChannel new_val 14;
  on VRayRawLighting changed new_val do current_state.updateChannel new_val 15;
  on VRayRawRefraction changed new_val do current_state.updateChannel new_val 16;
  on VRayRawShadow changed new_val do current_state.updateChannel new_val 17;
  on VRayRawTotalLighting changed new_val do current_state.updateChannel new_val 18;
  on VRayReflectionFilter changed new_val do current_state.updateChannel new_val 19;
  on VRayReflection changed new_val do current_state.updateChannel new_val 20;
  on VRayRefractionFilter changed new_val do current_state.updateChannel new_val 21;
  on VRayRefraction changed new_val do current_state.updateChannel new_val 22;
  on VRayRenderID changed new_val do current_state.updateChannel new_val 23;
  on VRaySelfIllumination changed new_val do current_state.updateChannel new_val 24;
  on VRayShadows changed new_val do current_state.updateChannel new_val 25;
  on VRaySpecular changed new_val do current_state.updateChannel new_val 26;
  on VRayTotalLighting changed new_val do current_state.updateChannel new_val 27;
  on VRayUnclampedColor changed new_val do current_state.updateChannel new_val 28;
  on VRayRawReflection changed new_val do current_state.updateChannel new_val 29;
  on VRayWireColor changed new_val do current_state.updateChannel new_val 30;
  );

fn manageUi new_val = (
  passesController.reset.enabled = new_val;
  passesController.suppress.enabled = new_val;
  passesController.listePasses.enabled = new_val;

  passesController.GI.enabled = new_val;
  if passesController.GI.checked
  then (
    passesController.primary_engine.enabled = new_val;
    passesController.primary_engine_preset.enabled = new_val;
    passesController.secondary_engine.enabled = new_val;
    )
  else(
    passesController.primary_engine.enabled = false;
    passesController.primary_engine_preset.enabled = false;
    passesController.secondary_engine.enabled = false;
    )

  passesController.AO.enabled = new_val;
  if passesController.AO.checked
  then (
    passesController.ao_occluded_color.enabled = new_val;
    passesController.ao_occluded_color_label.enabled = new_val;
    passesController.ao_unoccluded_color.enabled = new_val;
    passesController.ao_unoccluded_color_label.enabled = new_val;
    passesController.ao_radius.enabled = new_val;
    passesController.ao_falloff.enabled = new_val;
    )
  else(
    passesController.ao_occluded_color.enabled = false;
    passesController.ao_occluded_color_label.enabled = false;
    passesController.ao_unoccluded_color.enabled = false;
    passesController.ao_unoccluded_color_label.enabled = false;
    passesController.ao_radius.enabled = false;
    passesController.ao_falloff.enabled = false;
    )

  passesController.caustics.enabled = new_val;
  if passesController.caustics.checked
  then (
    passesController.caustics_search_dist.enabled = new_val;
    passesController.caustics_max_photons.enabled = new_val;
    passesController.caustics_max_density.enabled = new_val;
    passesController.search_dist_label.enabled = new_val;
    passesController.max_photons_label.enabled = new_val;
    passesController.max_density_label.enabled = new_val;
    )
  else (
    passesController.caustics_search_dist.enabled = false;
    passesController.caustics_max_photons.enabled = false;
    passesController.caustics_max_density.enabled = false;
    passesController.search_dist_label.enabled = false;
    passesController.max_photons_label.enabled = false;
    passesController.max_density_label.enabled = false;
    )

  passesController.image_sampler.enabled = new_val;
  passesController.advanced_image_sampler.enabled = new_val;

  passesController.time_output.enabled = new_val;
  passesController.range_start.enabled = new_val;
  passesController.range_end.enabled = new_val;
  passesController.size_output_width.enabled = new_val;
  passesController.size_output_height.enabled = new_val;
  passesController.range_start_label.enabled = new_val;
  passesController.range_end_label.enabled = new_val;
  passesController.size_output_width_label.enabled = new_val;
  passesController.size_output_height_label.enabled = new_val;

  passesController.Z.enabled = new_val;
  if passesController.Z.checked
  then (
    passesController.z_min.enabled = new_val;
    passesController.z_max.enabled = new_val;
    passesController.z_min_label.enabled = new_val;
    passesController.z_max_label.enabled = new_val;
    )
  else(
    passesController.z_min.enabled = false;
    passesController.z_max.enabled = false;
    passesController.z_min_label.enabled = false;
    passesController.z_max_label.enabled = false;
    )

  passesController.velocity.enabled = new_val;
  if passesController.velocity.checked
  then (
    passesController.max_velocity.enabled = new_val;
    passesController.ignore_z.enabled = new_val;
    passesController.max_velocity_label.enabled = new_val;
    passesController.ignore_z_label.enabled = new_val;
    )
  else(
    passesController.max_velocity.enabled = false;
    passesController.ignore_z.enabled = false;
    passesController.max_velocity_label.enabled = false;
    passesController.ignore_z_label.enabled = false;
    )

  passesController.add_light_select.enabled = new_val;
  passesController.liste_light_select.enabled = new_val;

  passesController.pick_matte_objects.enabled = new_val;
  passesController.liste_matte_objects.enabled = new_val;

  passesController.set_camera.enabled = new_val;
  passesController.set_path.enabled = new_val;
  passesController.render_all.enabled = new_val;

  passesController.MultiMatteElement.enabled = new_val;
  passesController.VRayAlph.enabled = new_val;
  passesController.VRayAtmosphere.enabled = new_val;
  passesController.VRayBackground.enabled = new_val;
  passesController.VRayCaustics.enabled = new_val;
  passesController.VRayDiffuseFilter.enabled = new_val;
  passesController.VRayGlobalIllumination.enabled = new_val;
  passesController.VRayLighting.enabled = new_val;
  passesController.VRayMatteShadow.enabled = new_val;
  passesController.VRayMtlID.enabled = new_val;
  passesController.VRayMtlSelect.enabled = new_val;
  passesController.VRayNormals.enabled = new_val;
  passesController.VRayObjectID.enabled = new_val;
  passesController.VRayRawGlobalIllumination.enabled = new_val;
  passesController.VRayRawLighting.enabled = new_val;
  passesController.VRayRawReflection.enabled = new_val;
  passesController.VRayRawRefraction.enabled = new_val;
  passesController.VRayRawShadow.enabled = new_val;
  passesController.VRayRawTotalLighting.enabled = new_val;
  passesController.VRayReflectionFilter.enabled = new_val;
  passesController.VRayReflection.enabled = new_val;
  passesController.VRayRefractionFilter.enabled = new_val;
  passesController.VRayRefraction.enabled = new_val;
  passesController.VRayRenderID.enabled = new_val;
  passesController.VRaySelfIllumination.enabled = new_val;
  passesController.VRayShadows.enabled = new_val;
  passesController.VRaySpecular.enabled = new_val;
  passesController.VRayTotalLighting.enabled = new_val;
  passesController.VRayUnclampedColor.enabled = new_val;
  passesController.VRayWireColor.enabled = new_val;

  if passesController.time_output.selected == 3
  then (
    passesController.range_start.enabled = true;
    passesController.range_end.enabled = true;
    passesController.range_start_label.enabled = true;
    passesController.range_end_label.enabled = true;
    )
  else(
    passesController.range_start.enabled = false;
    passesController.range_end.enabled = false;
    passesController.range_start_label.enabled = false;
    passesController.range_end_label.enabled = false;
    )

  if passesController.primary_engine.selection == 1 and passesController.primary_engine.enabled
  then ( passesController.primary_engine_preset.enabled = true; )
  else ( passesController.primary_engine_preset.enabled = false; )

  passesController.advanced_gi.enabled = passesController.GI.checked;
  passesController.render_all.enabled = general_ctrl.directory_set and general_ctrl.camera_set;
  );
