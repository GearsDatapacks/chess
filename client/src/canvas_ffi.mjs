import { Ok, Error } from "./gleam.mjs";
import { ElementNotFound, ElementNotCanvas, FailedToGetContext } from "./canvas.mjs";

export function getFromId(id) {
  let element = document.getElementById(id);
  if (element === null) {
    return new Error(new ElementNotFound());
  }
  if (element.nodeName !== "CANVAS") {
    return new Error(new ElementNotCanvas());
  }
  return new Ok(element);
}

export function getContext(canvas) {
  let context = canvas.getContext("2d");
  if (context == null) {
    return new Error(new FailedToGetContext());
  }
  return new Ok(context);
}

export function fillRect(context, colour, x, y, w, h) {
  context.fillStyle = colour;
  context.fillRect(x, y, w, h);
}

export function getWindowDimensions() {
  return [window.innerWidth, window.innerHeight];
}

export function drawImage(context, path, x, y, w, h) {
  const img = new Image();
  img.src = path;
  img.onload = () => {
    context.drawImage(img, x, y, w, h);
  }
}
