/* Generated by the Nim Compiler v2.0.2 */
var framePtr = null;
var excHandler = 0;
var lastJSError = null;
var objectID_1325400241 = [0];

function main() {
    
function createScene_1140850727(canvas_1140850728, engine_1140850729) {
      var result_1140850730 = null;

      BeforeRet: {
        var scene_1140850745 = (new BABYLON.Scene((engine_1140850729)));
        var camera_1140850823 = (new BABYLON.ArcRotateCamera(("camera"), (-1.5707963267948966), (1.2566370614359172), (3), ((new BABYLON.Vector3((0), (0), (0)))), (scene_1140850745)));
        camera_1140850823.attachControl((canvas_1140850728), (true));
        var light_1140850898 = (new BABYLON.HemisphericLight(("light"), ((new BABYLON.Vector3((0), (1), (0)))), (scene_1140850745)));
        var box_1140850931 = (new BABYLON.MeshBuilder.CreateBox(("box"), ({}), (scene_1140850745)));
        result_1140850730 = scene_1140850745;
        break BeforeRet;
      };

      return result_1140850730;

    }
    
function HEX3Aanonymous_1140850933() {
        scene_1140850932.render();

      
    }

    var canvas_1140850698 = document.getElementById("renderCanvas");
    var engine_1140850726 = (new BABYLON.Engine((canvas_1140850698)));
    var scene_1140850932 = createScene_1140850727(canvas_1140850698, engine_1140850726);
    engine_1140850726.runRenderLoop((HEX3Aanonymous_1140850933));

  
}
