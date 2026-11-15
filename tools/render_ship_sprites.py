"""Render the ship sprites in art/ship/ from the Meshy model (v0.3.1).

Usage, from the repo root:
  pip install trimesh moderngl pillow numpy scipy
  python3 -I tools/render_ship_sprites.py art_source/swallow_glider.glb <out_dir> [size] [--flip]
Then copy the five ship_bank_*.png files into art/ship/. Not part of the game build or the test gate.

Draws the model straight down (orthographic), nose pointing right (Godot's
angle 0), with a transparent background, soft toy lighting and a dark outline.
Writes one sprite per bank angle plus a contact sheet for review.
"""
import sys, os, math
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
    float shade = 0.62 + 0.45 * d;
    f_color = vec4(min(base * shade, vec3(1.0)), 1.0);
}
"""

def rot_x(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[1, 0, 0], [0, c, -s], [0, s, c]], dtype="f4")

def rot_y(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, 0, s], [0, 1, 0], [-s, 0, c]], dtype="f4")

def rot_z(a):
    c, s = math.cos(a), math.sin(a)
    return np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]], dtype="f4")

def main():
    src, out_dir = sys.argv[1], sys.argv[2]
    size = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3].isdigit() else 192
    flip = "--flip" in sys.argv
    os.makedirs(out_dir, exist_ok=True)

    scene = trimesh.load(src)
    geom = list(scene.geometry.values())[0]
    v = np.asarray(geom.vertices, dtype="f4")
    v -= (v.max(0) + v.min(0)) / 2.0
    n = np.asarray(geom.vertex_normals, dtype="f4")
    uv = np.asarray(geom.visual.uv, dtype="f4")
    f = np.asarray(geom.faces, dtype="i4")
    img = geom.visual.material.baseColorTexture.convert("RGB")

    # Meshy model: Y up, nose along -X (canopy sits at -X, wings sweep toward +X).
    # Turn it so the nose points along +X (Godot angle 0).
    yaw = rot_y(math.pi if not flip else 0.0)
    v = v @ yaw.T
    n = n @ yaw.T
    radius = float(np.linalg.norm(v[:, [0, 2]], axis=1).max())

    ctx = moderngl.create_context(standalone=True, backend="egl")
    prog = ctx.program(vertex_shader=VERT, fragment_shader=FRAG)
    data = np.hstack([v, n, uv]).astype("f4")
    vbo = ctx.buffer(data.tobytes())
    ibo = ctx.buffer(f.tobytes())
    vao = ctx.vertex_array(prog, [(vbo, "3f 3f 2f", "in_pos", "in_nrm", "in_uv")], ibo)
    tex = ctx.texture(img.size, 3, img.transpose(Image.FLIP_TOP_BOTTOM).tobytes())
    tex.build_mipmaps()
    tex.use(0)
    prog["tex"].value = 0
    prog["light_dir"].value = (-0.35, 1.0, 0.45)

    ss = 4
    big = size * ss
    fbo = ctx.simple_framebuffer((big, big), components=4)
    fbo.use()
    ctx.enable(moderngl.DEPTH_TEST)

    # Top-down: look down -Y. Screen x = world X, screen up = world -Z (so +X nose points right).
    view = np.array([[1, 0, 0], [0, 0, -1], [0, -1, 0]], dtype="f4")
    margin = 1.12
    scale = 1.0 / (radius * margin)

    frames = {}
    for deg in (0, 15, 30, -15, -30):
        roll = rot_x(math.radians(deg))
        r3 = view @ roll
        m = np.eye(4, dtype="f4")
        m[:3, :3] = r3 * scale
        m[2, :3] *= 0.5  # depth: higher Y is nearer the camera
        prog["mvp"].write(m.T.copy().tobytes())
        prog["rot"].write(roll.T.copy().tobytes())
        fbo.clear(0, 0, 0, 0, depth=1.0)
        vao.render()
        raw = Image.frombytes("RGBA", (big, big), fbo.read(components=4)).transpose(Image.FLIP_TOP_BOTTOM)
        # Outline: grow the alpha and paint it dark navy behind the ship.
        a = raw.getchannel("A")
        grown = a.filter(ImageFilter.MaxFilter(2 * ss + 1))
        outline = Image.new("RGBA", raw.size, (31, 59, 99, 255))
        outline.putalpha(grown)
        comp = Image.alpha_composite(outline, raw)
        sprite = comp.resize((size, size), Image.LANCZOS)
        name = "ship_bank_%s%02d.png" % ("p" if deg >= 0 else "m", abs(deg))
        sprite.save(os.path.join(out_dir, name))
        frames[deg] = sprite

    # Contact sheet on grass green for review.
    order = (-30, -15, 0, 15, 30)
    sheet = Image.new("RGBA", (size * len(order) + 10 * (len(order) + 1), size + 20), (86, 156, 74, 255))
    for i, deg in enumerate(order):
        sheet.alpha_composite(frames[deg], (10 + i * (size + 10), 10))
    sheet.save(os.path.join(out_dir, "contact_sheet.png"))
    print("radius", radius, "frames", sorted(frames))

if __name__ == "__main__":
    main()
