vr;
matte_shadow;
stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin";
stateSets = stateSetsDotNetObject.Instance;
masterState = stateSets.EntityManager.RootEntity.MasterStateSet;
re = maxOps.GetCurRenderElementMgr();

current_state;
backup;
ao;
general_ctrl;
LayerList;
MatteList;
LightList;
layers = #();
states = #();
