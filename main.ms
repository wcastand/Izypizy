fileIn "helper/settings.ms";
fileIn "helper/utility.ms";
fileIn "class/general.ms";
fileIn "class/layer.ms";
fileIn "class/state.ms";
fileIn "class/ui.ms";

fn init = (
  renderers.current = VRay();
  vr = renderers.current;
  matte_shadow = createMatteMaterial();
  createDialog passesController 1030 500;
  LayerList = passesController.listePasses;
  MatteList = passesController.liste_matte_objects;
  LightList = passesController.liste_light_select;
  general_ctrl = GeneralCtrl();
  general_ctrl.init();
  manageUI false;
  );

fn getLayers = (
  for i = 1 to layerManager.count - 1 do (
    temp = layerManager.getLayer(i);
    if temp.name != "safe" and temp.name != "Safe" do(
      ilayer = Layer name: temp.name layer: temp;
      append layers ilayer;
      );
    );
  );

fn generatePasse = (
  getLayers();
  --generate AO state
  stateSet = masterState.AddState();
  masterState.AssignUniqueName stateSet "AO";
  ao = State name: "AO" state: stateSet;
  ao.createRenderElement();
  append states ao;
  --generate backup state
  stateSet = masterState.AddState();
  masterState.AssignUniqueName stateSet "Backup";
  backup = State name: stateSet.Name state: stateSet;

  for i = 1 to layers.count do (
    stateSet = masterState.AddState();
    masterState.AssignUniqueName stateSet layers[i].name;
    istate = State name: stateSet.Name layer: layers[i].layer state: stateSet;
    istate.createRenderElement();
    append states istate;
    masterState.CurrentState = #(stateSet);
    istate.state.BeginRecording();
    setHidden i;
    istate.state.EndRecording();
    masterState.CurrentState = #(backup.state);
    stateSet = backup.state;
    --add to listbox
    LayerList.items = append LayerList.items istate.name;
    );
  selectPasse LayerList.items[1];
  manageUI true;
  );

fn resetPasse = (
  re.RemoveAllRenderElements();
  for i = 1 to states.count do ( masterState.RemoveChild states[i].state; )
  masterState.CurrentState = #(backup.state);
  backup.updateUI();
  backup.updateRenderElement();
  masterState.RemoveChild backup.state;
  masterState.CurrentState = #(ao.state);
  ao.updateUI();
  ao.updateRenderElement();
  masterState.RemoveChild ao.state;
  backup          = undefined;
  ao              = undefined;
  current_state   = undefined;
  layers          = #();
  states          = #();
  LayerList.items = #();
  MatteList.items = #();
  LightList.items = #();
  manageUI false;
  );

fn suppressPasse = (
  indexLayer = LayerList.selection;
  if indexLayer != 0 do(
    --layer delete
    deleteItem layers indexLayer;
    LayerList.items = deleteItem LayerList.items indexLayer;
    --state delete
    masterState.RemoveChild states[indexLayer].state;
    deleteItem states indexLayer;
    );
  );

init();
