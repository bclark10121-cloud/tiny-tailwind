"""Render the five ship sprites in art/ship/ from a Meshy model.

Usage, from the repo root:
  pip install trimesh moderngl pillow numpy scipy
  python3 -I tools/render_ship_sprites.py <model.glb> <out_dir> [--size 192] [--nose +y] [--up +z]
Then copy the five ship_bank_*.png files into art/ship/. Not part of the game build or the test gate.

--nose and --up name the model axes that point to the ship's nose and to its top (+x, -x, +y, -y, +z or -z).
The Manta (v0.3.2) came from one top-down image, so its nose is +y and its top is +z.
Each sprite looks straight down on the ship with the nose pointing right (Godot angle 0), a transparent
background, soft toy lighting and a navy outline. The ship's widest side fills 60/66 of the square, so a
66 px draw shows it 60 px across. Bank frames roll the ship 15 and 30 degrees each way. A positive bank
dips the ship's right wing.
"""
import sys, os, math, argparse
import numpy as np
import trimesh
import moderngl
from PIL import Image, ImageFilter

VERT = """
#version 330
uniform mat4 mvp;
uniform mat3 rot;
in vec3 in_pos; in vec3 in_nrm; in vec2 in_uv;
out vec3 v_nrm; out vec2 v_uv;
void main() {
    gl_Position = mvp * vec4(in_pos, 1.0);
    v_nrm = rot * in_nrm;
    v_uv = in_uv;
}
"""
FRAG = """
#version 330
uniform sampler2D tex;
uniform vec3 light_dir;
in vec3 v_nrm; in vec2 v_uv;
out vec4 f_color;
void main() {
    vec3 base = texture(tex, v_uv).rgb;
    float d = max(dot(normalize(v_nrm), normalize(light_dir)), 0.0);
    float shade = 0.66 + 0.40 * d;
    f_color = vec4(min(base * shade, vec3(1.0)), 1.0);
}
"""

AXES = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1), "-z": (0, 0, -1)}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("model"); ap.add_argument("out")
    ap.add_argument("--size", type=int, default=192)
    ap.add_argument("--nose", default="+y"); ap.add_argument("--up", default="+z")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)

    scene = trimesh.load(a.model)
    geom = list(scene.geometry.values())[0]
    v = np.asarray(geom.vertices, dtype="f4")
    v -= (v.max(0) + v.min(0)) / 2.0
    n = np.asarray(geom.vertex_normals, dtype="f4")
    uv = np.asarray(geom.visual.uv, dtype="f4")
    f = np.asarray(geom.faces, dtype="i4")
    img = geom.visual.material.baseColorTexture.convert("RGB")

    # Turn the model into ship space: nose +X, top +Y, right wing +Z.
    nose = np.array(AXES[a.nose], dtype="f4"); up = np.array(AXES[a.up], dtype="f4")
    right = np.cross(nose, up)
    to_ship = np.stack([nose, up, right])          # rows: new X, Y, Z in model coordinates
    v = v @ to_ship.T
    n = n @ to_ship.T

    ctx = moderngl.create_context(standalone=True, backend="egl")
    prog = ctx.program(vertex_shader=VERT, fragment_shader=FRAG)
    vbo = ctx.buffer(np.hstack([v, n, uv]).astype("f4").tobytes())
    ibo = ctx.buffer(f.tobytes())
    vao = ctx.vertex_array(prog, [(vbo, "3f 3f 2f", "in_pos", "in_nrm", "in_uv")], ibo)
    tex = ctx.texture(img.size, 3, img.transpose(Image.FLIP_TOP_BOTTOM).tobytes())
    tex.build_mipmaps(); tex.use(0)
    prog["tex"].value = 0
    prog["light_dir"].value = (-0.35, 1.0, -0.45)   # from above, a little from the tail and the left wing

    ss = 4
    big = a.size * ss
    fbo = ctx.simple_framebuffer((big, big), components=4)
    fbo.use()
    ctx.enable(moderngl.DEPTH_TEST)

    # Look straight down -Y. Screen right = +X (nose), screen up = -Z (left wing), nearer = higher Y.
    view = np.array([[1, 0, 0], [0, 0, -1], [0, -0.5, 0]], dtype="f4")
    half = float(max(np.abs(v[:, 0]).max(), np.abs(v[:, 2]).max()))
    scale = (60.0 / 66.0) / half

    def roll(deg):
        c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
        return np.array([[1, 0, 0], [0, c, -s], [0, s, c]], dtype="f4")   # +deg lifts the left wing (-Z)

    frames = {}
    for deg in (0, 15, 30, -15, -30):
        r = roll(deg)
        m = np.eye(4, dtype="f4")
        m[:3, :3] = (view @ r) * scale
        prog["mvp"].write(m.T.copy().tobytes())
        prog["rot"].write(r.T.copy().tobytes())
        fbo.clear(0, 0, 0, 0, depth=1.0)
        vao.render()
        raw = Image.frombytes("RGBA", (big, big), fbo.read(components=4)).transpose(Image.FLIP_TOP_BOTTOM)
        grown = raw.getchannel("A").filter(ImageFilter.MaxFilter(2 * ss + 1))
        outline = Image.new("RGBA", raw.size, (31, 59, 99, 255))
        outline.putalpha(grown)
        sprite = Image.alpha_composite(outline, raw).resize((a.size, a.size), Image.LANCZOS)
        name = "ship_bank_%s%02d.png" % ("p" if deg >= 0 else "m", abs(deg))
        sprite.save(os.path.join(a.out, name))
        frames[deg] = sprite

    order = (-30, -15, 0, 15, 30)
    sheet = Image.new("RGBA", (a.size * 5 + 60, a.size + 20), (86, 156, 74, 255))
    for i, deg in enumerate(order):
        sheet.alpha_composite(frames[deg], (10 + i * (a.size + 10), 10))
    sheet.save(os.path.join(a.out, "contact_sheet.png"))
    print("rendered", sorted(frames), "half extent", round(half, 3))

if __name__ == "__main__":
    main()
