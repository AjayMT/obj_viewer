let vec3_normalize (a, b, c) =
  let mag = sqrt ((a *. a) +. (b *. b) +. (c *. c)) in
  (a /. mag, b /. mag, c /. mag)

let vec3_add (a, b, c) (d, e, f) = (a +. d, b +. e, c +. f)

let vec3_sub (a, b, c) (d, e, f) = (a -. d, b -. e, c -. f)

let vec3_cross (a, b, c) (d, e, f) =
  ((b *. f) -. (c *. e), -1.0 *. ((a *. f) -. (c *. d)), (a *. e) -. (b *. d))

let read_obj obj_data =
  let lines =
    List.map (Str.split (Str.regexp "[ \n\r\x0c\t]+"))
    @@ Str.split (Str.regexp "[\n\r]+") obj_data
  in
  let vertex_lines = List.filter (fun s -> List.hd s = "v") lines in
  let face_lines = List.filter (fun s -> List.hd s = "f") lines in

  let vertices =
    Array.of_list
    @@ List.map
         (fun line ->
           let nums = List.tl line in
           ( float_of_string @@ List.nth nums 0,
             float_of_string @@ List.nth nums 1,
             float_of_string @@ List.nth nums 2 ))
         vertex_lines
  in

  let faces =
    List.map
      (fun line ->
        let idxs = List.map (fun s -> int_of_string s - 1) @@ List.tl line in
        (List.nth idxs 0, List.nth idxs 1, List.nth idxs 2))
      face_lines
  in

  let normals = Array.make (Array.length vertices) (0.0, 0.0, 0.0) in
  List.iter
    (fun (v1, v2, v3) ->
      let e1 = vec3_sub vertices.(v2) vertices.(v1) in
      let e2 = vec3_sub vertices.(v3) vertices.(v1) in
      let n = vec3_cross e1 e2 in
      normals.(v1) <- vec3_add n normals.(v1);
      normals.(v2) <- vec3_add n normals.(v2);
      normals.(v3) <- vec3_add n normals.(v3))
    faces;

  (vertices, faces, normals)

let render_obj obj =
  let vertices, faces, normals = obj in
  let draw_face face =
    let v1, v2, v3 = face in
    GlDraw.normal3 normals.(v1);
    GlDraw.vertex3 vertices.(v1);
    GlDraw.normal3 normals.(v2);
    GlDraw.vertex3 vertices.(v2);
    GlDraw.normal3 normals.(v3);
    GlDraw.vertex3 vertices.(v3)
  in
  GlDraw.begins `triangles;
  List.iter draw_face faces;
  GlDraw.ends ()

let _ =
  let obj_name = Sys.argv.(1) in
  let obj_data =
    let in_ch = open_in obj_name in
    really_input_string in_ch (in_channel_length in_ch)
  in
  let obj = read_obj obj_data in

  Glut.initDisplayMode ~double_buffer:true ~depth:true ~alpha:true ();
  Glut.initWindowSize ~w:500 ~h:500;
  ignore @@ Glut.init ~argv:Sys.argv;
  ignore @@ Glut.createWindow ~title:"hello world";

  let light_ambient = (1.0, 1.0, 1.0, 1.0) in
  let light_diffuse = (1.0, 1.0, 1.0, 1.0) in
  let light_specular = (1.0, 1.0, 1.0, 1.0) in
  let light_position = (5.0, 5.0, 5.0, 0.0) in
  GlLight.light ~num:0 (`ambient light_ambient);
  GlLight.light ~num:0 (`diffuse light_diffuse);
  GlLight.light ~num:0 (`specular light_specular);
  GlLight.light ~num:0 (`position light_position);

  GlFunc.depth_func `less;
  List.iter Gl.enable [ `lighting; `light0; `depth_test ];

  let x_angle = ref 0.0 in
  let y_angle = ref 0.0 in
  let z_shift = ref 0.0 in

  Glut.specialFunc ~cb:(fun ~key ~x ~y ->
      ignore x;
      ignore y;
      let redisplay =
        match key with
        | Glut.KEY_LEFT ->
            y_angle := !y_angle +. 10.0;
            true
        | Glut.KEY_RIGHT ->
            y_angle := !y_angle -. 10.0;
            true
        | Glut.KEY_UP ->
            x_angle := !x_angle +. 10.0;
            true
        | Glut.KEY_DOWN ->
            x_angle := !x_angle -. 10.0;
            true
        | _ -> false
      in
      if redisplay then Glut.postRedisplay () else ());

  Glut.keyboardFunc ~cb:(fun ~key ~x ~y ->
      ignore x;
      ignore y;
      let redisplay =
        match key with
        (* + and - keys *)
        | 61 ->
            z_shift := !z_shift +. 0.3;
            true
        | 45 ->
            z_shift := !z_shift -. 0.3;
            true
        | _ -> false
      in
      if redisplay then Glut.postRedisplay () else ());

  Glut.reshapeFunc ~cb:(fun ~w ~h ->
      GlDraw.viewport ~x:0 ~y:0 ~w ~h;
      GlMat.mode `projection;
      GlMat.load_identity ();
      GluMat.perspective ~fovy:45.0
        ~aspect:(float_of_int w /. float_of_int h)
        ~z:(0.1, 500.0);
      GluMat.look_at ~eye:(0.0, 0.0, 10.0) ~center:(0.0, 0.0, 0.0)
        ~up:(0.0, 1.0, 0.0);
      GlMat.mode `modelview;
      GlMat.load_identity ());

  Glut.displayFunc ~cb:(fun () ->
      GlClear.color (0.0, 0.0, 0.0);
      GlClear.clear [ `color; `depth ];

      GlMat.push ();
      GlMat.translate ~z:!z_shift ();
      GlMat.rotate ~angle:!x_angle ~x:1.0 ();
      GlMat.rotate ~angle:!y_angle ~y:1.0 ();
      render_obj obj;
      GlMat.pop ();

      Glut.swapBuffers ());

  Glut.mainLoop ()
