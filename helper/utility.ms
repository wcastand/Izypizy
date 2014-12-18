fn createMatteMaterial = (
  matte_shadow = VRayMtlWrapper();
  matte_shadow.name = "matte_shadow";
  matte_shadow.matteSurface = true;
  matte_shadow.alphaContribution = -1;
  matte_shadow.matte_shadows = true;
  matte_shadow.matte_shadowsAffectAlpha = true;
  matte_shadow.baseMtl = VRayMtl();
  return matte_shadow;
  );

fn setMatteShadow n = (
        n.material = matte_shadow;
  );

fn setHidden layerIndex = (
  for i = 1 to layers.count do (
    local theNodes = undefined;
    if i != layerIndex do(
      layers[i].layer.nodes &theNodes;
      for i= 1 to theNodes.count do (
        hide theNodes[i];
        );
      );
    );
  );

fn selectPasse name = (
  for i = 1 to states.count do (
    if states[i].name == name
    then (
      if name == "AO"
      then general_ctrl.updateAO true;
      else (
        current_state = states[i];
        masterState.CurrentState = #(current_state.state);
        current_state.updateUI();
        current_state.updateRenderElement();
        current_state.updateMatteList();
        current_state.state.BeginRecording();
        )
      )
    );
  general_ctrl.applyToAllState "all";
  manageUI true;
  );
