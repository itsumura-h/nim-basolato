import std/asyncjs
import std/dom
import std/jscore
import std/jsconsole
import std/jsfetch
import std/jsffi
import std/math


let BABYLON {.importc.}: JsObject

proc babylonMain*(ev:Event) {.exportc.} =
  console.log("=== main start")
  let canvas = document.getElementById("renderCanvas")
  let engine = jsNew BABYLON.Engine(canvas)

  # ここから
  proc createScene(canvas:Element, engine:JsObject):JsObject =
    # シーンを作成
    let scene = BABYLON.Scene(engine).jsNew()
    # カメラを作成
    let camera = BABYLON.ArcRotateCamera(
      "camera",
      -(PI / 2),
      PI / 2.5,
      3,
      jsNew BABYLON.Vector3(0, 0, 0),
      scene
    )
    .jsNew()

    # カメラがユーザからの入力で動くように
    camera.attachControl(canvas, true)
    # ライトを作成
    let light = BABYLON.HemisphericLight("light", jsNew BABYLON.Vector3(0, 1, 0), scene).jsNew()
    # 箱 (豆腐) を作成
    let box = BABYLON.MeshBuilder.CreateBox("box", newJsObject(), scene).jsNew()
    return scene
 
  let scene = createScene(canvas, engine)
  engine.runRenderLoop(
    proc() = scene.render()
  )
  console.log("=== main end")

window.addEventListener("DOMContentLoaded", babylonMain)
# window.addEventListener("turbo:load", babylonMain)

#[

function main() {
  const canvas = document.getElementById('renderCanvas');
  const engine = new BABYLON.Engine(canvas);
  // ここから
  function createScene() {
    // シーンを作成
    const scene = new BABYLON.Scene(engine);
    // カメラを作成
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 3, new BABYLON.Vector3(0, 0, 0), scene);
    // カメラがユーザからの入力で動くように
    camera.attachControl(canvas, true);
    // ライトを作成
    const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
    // 箱 (豆腐) を作成
    const box = BABYLON.MeshBuilder.CreateBox("box", {}, scene);
    return scene;
  }
  
  const scene = createScene();
  
  engine.runRenderLoop(() => {
    scene.render();
  });
  
  window.addEventListener('resize', () => {
    engine.resize();
  });
}
window.addEventListener('DOMContentLoaded', main);

]#
