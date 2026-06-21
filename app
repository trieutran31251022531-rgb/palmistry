import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from PIL import Image, ImageTk
import numpy as np
import cv2
import threading
from tensorflow.keras.models import load_model

FORTUNE_TEXTS = {
    "Sinh đạo dài": "Sinh khí dồi dào, thể lực tốt và khả năng thích nghi cao. Cuộc sống thường gặp nhiều thuận lợi khi biết nắm bắt cơ hội.",

    "Sinh đạo ngắn": "Nguồn năng lượng có phần thất thường. Nên chú trọng nghỉ ngơi và giữ cân bằng để vận trình ổn định hơn.",

    "Tâm đạo rõ": "Là người chân thành, giàu tình cảm và sống hết lòng vì các mối quan hệ. Dễ nhận được sự yêu mến từ người xung quanh.",

    "Tâm đạo mờ": "Nội tâm kín đáo, ít bộc lộ cảm xúc. Khi biết mở lòng đúng lúc, nhân duyên sẽ thuận lợi hơn.",

    "Trí đạo thẳng": "Tư duy logic, thực tế và quyết đoán. Thường thành công nhờ sự rõ ràng và khả năng nhìn nhận vấn đề khách quan.",

    "Trí đạo cong": "Giàu trí tưởng tượng và khả năng sáng tạo. Dễ nổi bật trong những lĩnh vực cần ý tưởng và cảm hứng."
}

OVERALL_FORTUNES = {
    "mo_cong_dai": "Bản mệnh là người sống nội tâm, lý trí trong tình cảm nhưng lại rất bay bổng trong tư duy công việc. Thể lực tốt là một bệ phóng vững chắc giúp bạn theo đuổi con đường nghệ thuật hoặc sáng tạo lâu dài. Tình duyên có thể đến muộn do sự kín đáo, nhưng khi đã kết nối thì vô cùng bền chặt.",
    "mo_cong_ngan": "Sở hữu tâm hồn nghệ sĩ và tư duy phong phú, song thể trạng lại có phần nhạy cảm, dễ hao tổn tâm lực. Trong tình cảm, bạn kín đáo và ít bộc lộ. Cần đặc biệt chú ý cân bằng giữa đam mê sáng tạo và việc nghỉ ngơi. Cuộc đời cần tìm được một người bạn đời thực sự thấu hiểu để làm chỗ dựa tinh thần.",
    "mo_thang_dai": "Tướng tay của người cực kỳ thực tế, tư duy sắc bén và đậm chất lý trí. Kết hợp với sinh lực dồi dào, bạn sinh ra để gánh vác các vị trí lãnh đạo hoặc làm kinh doanh lớn. Ít bị chi phối bởi sự ủy mị của tình cảm, bạn dễ dàng đưa ra các quyết định chính xác và gặt hái thành tựu vang dội.",
    "mo_thang_ngan": "Rất quyết đoán, sắc sảo và luôn nhìn nhận vấn đề một cách thực tế. Tuy nhiên, sức khỏe là điểm yếu cần lưu tâm. Bạn thường dồn hết tâm trí và sức lực cho công danh sự nghiệp, khiến tình cảm đôi khi bị xem nhẹ. Lời khuyên là hãy học cách điều tiết cảm xúc và dành thời gian chăm sóc bản thân.",
    "ro_cong_dai": "Trái tim vô cùng ấm áp, sống tình cảm, lãng mạn và bao dung. Trí tuệ bay bổng cộng hưởng với sức khỏe tốt giúp bạn biết cách tận hưởng vẻ đẹp của cuộc sống. Người có tướng tay này thường thu hút quý nhân, có nhân duyên vô cùng tốt đẹp và dễ có một cuộc đời bình an, viên mãn.",
    "ro_cong_ngan": "Bản mệnh nhạy cảm, dễ rung động và vô cùng giàu lòng trắc ẩn. Điểm cần lưu ý là thể lực yếu, dễ bị cảm xúc chi phối làm ảnh hưởng đến sức khỏe tinh thần lẫn thể chất. Để cải thiện vận trình, cần học cách buông bỏ những muộn phiền không đáng có và tránh suy nghĩ quá độ.",
    "ro_thang_dai": "Sự cân bằng tuyệt vời của tạo hóa: Trong tình cảm thì chân thành, nồng nhiệt, nhưng trong công việc lại vô cùng logic và rõ ràng. Thể lực dồi dào giúp bạn kiên trì vượt qua mọi sóng gió. Tài lộc và sự nghiệp thường rộng mở, đường tình duyên cũng ấm êm nhờ biết dung hòa giữa lý trí và con tim.",
    "ro_thang_ngan": "Một người yêu thương hết mình nhưng lại giải quyết vấn đề bằng cái đầu lạnh. Sự quyết đoán giúp bạn dễ gặt hái thành công trong sự nghiệp. Dù vậy, hãy cẩn thận đừng làm việc quá sức hay ôm đồm quá nhiều trách nhiệm. Tình duyên nhìn chung êm đẹp nếu bạn biết cân đối thời gian cho gia đình."
}

C = {
    "bg_deep":    "#0B0914",  
    "bg_mid":     "#161224",  
    "bg_card":    "#231C3B", 
    "bg_surface": "#2D244C",  
    "border":     "#4A3B73",  
    "divider":    "#352A5A",  
    "gold":       "#D4AF37",  
    "gold_light": "#F9E596", 
    "gold_glow":  "#FFDF73", 
    "sinh":       "#45A29E",  
    "sinh_muted": "#204F4D",
    "tam":        "#D94862",  
    "tam_muted":  "#63212C",
    "tri":        "#5C85A6",  
    "tri_muted":  "#2A3E4D",
    "text_bright": "#F4F0FF",
    "text_mid":    "#B8AEE0", 
    "text_dim":    "#786E9C", 
    "ok":          "#45A29E",
    "warn":        "#D4AF37",
    "err":         "#D94862",
    "btn_upload":  "#352A5A",
    "btn_camera":  "#281B45",
    "btn_capture": "#4A3B73",
    "btn_analyze": "#452A63",
    "btn_clear":   "#161224",
    "btn_upload_h": "#4A3B73",
    "btn_camera_h": "#3D2B66",
    "btn_capture_h": "#604E8F",
    "btn_analyze_h": "#60398A",
    "btn_clear_h":  "#2D244C",
}

MODEL_INPUT_SIZE = (224, 224) 
DISPLAY_W, DISPLAY_H = 460, 340
MODEL_PATH = "model_chitay_8_classes.h5"

CLASS_NAMES = [
    "mo_cong_dai", 
    "mo_cong_ngan", 
    "mo_thang_dai", 
    "mo_thang_ngan",
    "ro_cong_dai", 
    "ro_cong_ngan", 
    "ro_thang_dai", 
    "ro_thang_ngan"
]

def decode_class_name(class_name):
    parts = class_name.split('_')
    tam_dao_val  = "Tâm đạo mờ" if parts[0] == "mo" else "Tâm đạo rõ"
    tri_dao_val  = "Trí đạo cong" if parts[1] == "cong" else "Trí đạo thẳng"
    sinh_dao_val = "Sinh đạo dài" if parts[2] == "dai" else "Sinh đạo ngắn"
    return sinh_dao_val, tam_dao_val, tri_dao_val

def make_button(parent, text, command, bg, hover_bg, **kwargs):
    btn = tk.Button(
        parent, text=text, command=command,
        bg=bg, fg=C["text_bright"],
        activebackground=hover_bg,
        activeforeground=C["gold_glow"],
        relief="flat", bd=0,
        highlightthickness=1,
        highlightbackground=C["border"],
        highlightcolor=C["gold"],
        cursor="hand2",
        **kwargs
    )
    btn.bind("<Enter>", lambda e: btn.config(bg=hover_bg))
    btn.bind("<Leave>", lambda e: btn.config(bg=bg))
    return btn

class PalmistryApp:
    def __init__(self, root):
        self.root = root
        self.root.title("✧ Huyền Học Chỉ Tay — Thấu Hiểu Mệnh Lý")
        self.root.geometry("1100x820")
        self.root.configure(bg=C["bg_deep"])

        self.current_image     = None
        self.camera            = None
        self.is_camera_running = False
        self.model             = None

        self.setup_ui()
        self.load_models_async()

    def load_models_async(self):
        def _load():
            try:
                self.model = load_model(MODEL_PATH)
                self.status_label.config(
                    text="✧ Hệ thống AI đã được kích hoạt", fg=C["ok"])
            except Exception as e:
                self.status_label.config(
                    text=f"✗ Lỗi nạp mô hình: {str(e)[:60]}", fg=C["err"])
        threading.Thread(target=_load, daemon=True).start()

    def setup_ui(self):
   
        header = tk.Frame(self.root, bg=C["bg_mid"], pady=12)
        header.pack(side="top", fill="x")

        tk.Frame(header, bg=C["gold"], height=2).pack(fill="x", side="bottom")
        tk.Frame(header, bg=C["border"], height=1).pack(fill="x", side="top")

        title_frame = tk.Frame(header, bg=C["bg_mid"])
        title_frame.pack()

        tk.Label(
            title_frame, text="🌙Lunaris🌙 ",
            font=("Georgia", 24, "bold"), bg=C["bg_mid"], fg=C["gold"]
        ).pack()

        tk.Label(
            title_frame, text="Khám phá vận mệnh qua đường chỉ tay",
            font=("Georgia", 11, "italic"), bg=C["bg_mid"], fg=C["text_mid"]
        ).pack(pady=(2, 0))

      
        status_bar = tk.Frame(self.root, bg=C["bg_deep"], pady=3)
        status_bar.pack(side="top", fill="x", padx=20)

        self.status_label = tk.Label(
            status_bar, text="⏳ Đang tải mô hình phân tích...",
            font=("Georgia", 9, "italic"), bg=C["bg_deep"], fg=C["warn"]
        )
        self.status_label.pack(anchor="w")

        res_outer = tk.Frame(self.root, bg=C["bg_deep"], pady=0)
        res_outer.pack(side="bottom", fill="x", padx=14, pady=(0, 14))

        tk.Frame(res_outer, bg=C["gold"], height=1).pack(fill="x")

        res_frame = tk.Frame(res_outer, bg=C["bg_mid"], pady=10, padx=12)
        res_frame.pack(fill="x")

        tk.Label(
            res_frame, text="✧ Kết Quả Luận Giải ✧",
            font=("Georgia", 14, "bold italic"), bg=C["bg_mid"], fg=C["gold_light"]
        ).pack(pady=(0, 10))

        cols = tk.Frame(res_frame, bg=C["bg_mid"])
        cols.pack(fill="x")
        cols.columnconfigure(0, weight=1)
        cols.columnconfigure(1, weight=1)
        cols.columnconfigure(2, weight=1)

        self.sinh_frame = self._make_result_card(cols, "🌿 Sinh Đạo", C["sinh"], C["sinh_muted"])
        self.sinh_frame.grid(row=0, column=0, padx=6, sticky="nsew")

        self.tam_frame = self._make_result_card(cols, "❤ Tâm Đạo", C["tam"], C["tam_muted"])
        self.tam_frame.grid(row=0, column=1, padx=6, sticky="nsew")

        self.tri_frame = self._make_result_card(cols, "✒ Trí Đạo", C["tri"], C["tri_muted"])
        self.tri_frame.grid(row=0, column=2, padx=6, sticky="nsew")

     
        self.conclusion_frame = tk.Frame(res_frame, bg=C["bg_card"], padx=15, pady=10, highlightthickness=1, highlightbackground=C["border"])
        self.conclusion_frame.pack(fill="x", pady=(15, 5), padx=6)
        
        tk.Label(
            self.conclusion_frame, text="📜 Lời bói tổng quan:", 
            font=("Georgia", 11, "bold"), bg=C["bg_card"], fg=C["gold"]
        ).pack(anchor="w", pady=(0, 4))
        
        self.conclusion_label = tk.Label(
            self.conclusion_frame, text="Đang chờ hình ảnh bàn tay để xem bói...",
            font=("Georgia", 11, "italic"), bg=C["bg_card"], fg=C["text_bright"],
            wraplength=1000, justify="left"
        )
        self.conclusion_label.pack(fill="x", anchor="w")

     
        main_frame = tk.Frame(self.root, bg=C["bg_deep"])
        main_frame.pack(side="top", fill="both", expand=True, padx=14, pady=6)

     
        left = tk.Frame(main_frame, bg=C["bg_mid"], padx=16, pady=16,
                        highlightthickness=1, highlightbackground=C["border"])
        left.pack(side="left", fill="y", padx=(0, 10))

        tk.Frame(left, bg=C["gold"], height=2).pack(fill="x", pady=(0, 14))

        btn_cfg = dict(font=("Georgia", 11, "bold"), width=18, pady=8)

        self.upload_btn = make_button(
            left, "📁 Tải Ảnh", self.upload_image,
            C["btn_upload"], C["btn_upload_h"], **btn_cfg)
        self.upload_btn.pack(pady=5)

        self.camera_btn = make_button(
            left, "📷 Mở Camera", self.toggle_camera,
            C["btn_camera"], C["btn_camera_h"], **btn_cfg)
        self.camera_btn.pack(pady=5)

        self.capture_btn = make_button(
            left, "📸 Chụp Ảnh", self.capture_image,
            C["btn_capture"], C["btn_capture_h"], **btn_cfg)
        self.capture_btn.config(state="disabled")
        self.capture_btn.pack(pady=5)

        tk.Frame(left, bg=C["divider"], height=1).pack(fill="x", pady=8)

        self.analyze_btn = make_button(
            left, "🔮 Bắt Đầu Xem Bói", self.analyze_image,
            C["btn_analyze"], C["btn_analyze_h"], **btn_cfg)
        self.analyze_btn.config(state="disabled")
        self.analyze_btn.pack(pady=5)

        self.clear_btn = make_button(
            left, "✕ Làm Lại", self.clear_all,
            C["btn_clear"], C["btn_clear_h"], **btn_cfg)
        self.clear_btn.pack(pady=5)

     
        tk.Frame(left, bg=C["border"], height=1).pack(fill="x", pady=12)
        tk.Label(
            left, text=f"Chuẩn ảnh: {MODEL_INPUT_SIZE[0]}×{MODEL_INPUT_SIZE[1]} px",
            font=("Georgia", 8, "italic"), bg=C["bg_mid"], fg=C["text_dim"]
        ).pack()

        center = tk.Frame(main_frame, bg=C["bg_deep"])
        center.pack(side="left", fill="both", expand=True)

        outer_border = tk.Frame(center, bg=C["gold"], padx=3, pady=3)
        outer_border.pack(pady=8)
        inner_border = tk.Frame(outer_border, bg=C["bg_deep"], padx=6, pady=6)
        inner_border.pack()

        self.image_label = tk.Label(
            inner_border,
            text="✧\n\nXin mời cung cấp hình ảnh\nbàn tay cần xem bói",
            font=("Georgia", 13, "italic"), bg=C["bg_card"], fg=C["text_dim"],
            width=DISPLAY_W // 10, height=DISPLAY_H // 18,
        )
        self.image_label.pack()

        self.image_info = tk.Label(
            center, text="", font=("Georgia", 9, "italic"),
            bg=C["bg_deep"], fg=C["text_mid"]
        )
        self.image_info.pack(pady=(4, 0))

    def _make_result_card(self, parent, title, accent, muted):
        outer = tk.Frame(parent, bg=accent, padx=1, pady=1)
        inner = tk.Frame(outer, bg=C["bg_card"], padx=10, pady=8)
        inner.pack(fill="both", expand=True)

        tk.Frame(inner, bg=accent, height=2).pack(fill="x", pady=(0, 6))

        tk.Label(
            inner, text=title, font=("Georgia", 11, "bold"),
            bg=C["bg_card"], fg=accent
        ).pack()

        res_lbl = tk.Label(
            inner, text="—", font=("Georgia", 13, "bold"),
            bg=C["bg_card"], fg=C["text_bright"], width=18
        )
        res_lbl.pack(pady=(6, 4))

        meaning_lbl = tk.Label(
            inner, text="", font=("Georgia", 9, "italic"), bg=C["bg_card"],
            fg=C["gold_light"], wraplength=290, justify="center"
        )
        meaning_lbl.pack(pady=(2, 4), fill="both", expand=True)

        outer.result_label  = res_lbl
        outer.meaning_label = meaning_lbl
        return outer
    def preprocess(self, img: Image.Image) -> np.ndarray:
        img = img.convert("RGB")
        img = img.resize(MODEL_INPUT_SIZE, Image.Resampling.LANCZOS)
        arr = np.array(img, dtype=np.float32) / 255.0
        return arr.reshape(1, MODEL_INPUT_SIZE[0], MODEL_INPUT_SIZE[1], 3)

    def upload_image(self):
        path = filedialog.askopenfilename(
            title="Chọn ảnh bàn tay",
            filetypes=[("Image files", "*.jpg *.jpeg *.png *.bmp *.gif"), ("All files", "*.*")])
        if not path:
            return
        if self.is_camera_running:
            self.toggle_camera()
        self.current_image = Image.open(path).convert("RGB")
        self.display_image(self.current_image)
        self.analyze_btn.config(state="normal")
        self.image_info.config(text=f"📁 Lấy ảnh từ: {path.split('/')[-1]}")

    def toggle_camera(self):
        if self.is_camera_running:
            self.stop_camera()
        else:
            self.start_camera()

    def start_camera(self):
        self.camera = cv2.VideoCapture(0)
        if not self.camera.isOpened():
            messagebox.showerror("Lỗi", "Không thể mở camera!")
            return
        self.is_camera_running = True
        self.camera_btn.config(text="⏹ Đóng Camera", bg=C["btn_clear"])
        self.capture_btn.config(state="normal")
        self.analyze_btn.config(state="disabled")
        self.current_image = None
        self._update_camera()

    def _update_camera(self):
        if not self.is_camera_running or self.camera is None:
            return
        ret, frame = self.camera.read()
        if ret:
            kernel = np.array([[0, -1, 0],                        
                                         [-1, 5,-1],                           
                                         [0, -1, 0]])                           
            frame = cv2.filter2D(frame, -1, kernel)           
            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            pil_img   = Image.fromarray(frame_rgb)
            self.image_label.camera_frame = pil_img
            disp  = pil_img.resize((DISPLAY_W, DISPLAY_H), Image.Resampling.LANCZOS)
            photo = ImageTk.PhotoImage(disp)
            self.image_label.config(image=photo, text="", width=DISPLAY_W, height=DISPLAY_H)
            self.image_label.image = photo
        self.root.after(30, self._update_camera)

    def stop_camera(self):
        self.is_camera_running = False
        if self.camera:
            self.camera.release()
            self.camera = None
        self.camera_btn.config(text="📷 Mở Camera", bg=C["btn_camera"])
        self.capture_btn.config(state="disabled")

    def capture_image(self):
        if not hasattr(self.image_label, "camera_frame"):
            return
        self.current_image = self.image_label.camera_frame.copy()
        self.stop_camera()
        self.display_image(self.current_image)
        self.analyze_btn.config(state="normal")
        self.image_info.config(text="📸 Đã lưu hình ảnh thủ ấn")

    def display_image(self, img: Image.Image):
        disp = img.copy()
        disp.thumbnail((DISPLAY_W, DISPLAY_H), Image.Resampling.LANCZOS)
        photo = ImageTk.PhotoImage(disp)
        self.image_label.config(image=photo, text="", width=disp.width, height=disp.height)
        self.image_label.image = photo

    def analyze_image(self):
        if self.current_image is None:
            messagebox.showwarning("Nhắc nhở", "Vui lòng cung cấp hình ảnh bàn tay để xem bói!")
            return
        if self.model is None:
            messagebox.showerror("Lỗi", "Hệ thống AI chưa sẵn sàng, vui lòng đợi!")
            return

        img_array = self.preprocess(self.current_image)
        self.status_label.config(text="✧ AI đang phân tích dữ liệu chỉ tay...", fg=C["warn"])
        self.root.update()

        try:
            
            predictions = self.model.predict(img_array, verbose=0)[0]
            predicted_index = int(np.argmax(predictions))
            predicted_class_name = CLASS_NAMES[predicted_index]
            
            
            res_sinh_text, res_tam_text, res_tri_text = decode_class_name(predicted_class_name)

    
            self.sinh_frame.result_label.config(text=res_sinh_text)
            self.sinh_frame.meaning_label.config(text=FORTUNE_TEXTS.get(res_sinh_text, ""))

  
            self.tam_frame.result_label.config(text=res_tam_text)
            self.tam_frame.meaning_label.config(text=FORTUNE_TEXTS.get(res_tam_text, ""))

            self.tri_frame.result_label.config(text=res_tri_text)
            self.tri_frame.meaning_label.config(text=FORTUNE_TEXTS.get(res_tri_text, ""))

            overall_meaning = OVERALL_FORTUNES.get(predicted_class_name, "Không rõ số mệnh.")
            self.conclusion_label.config(text=overall_meaning)

            self.status_label.config(text="✧ Hoàn tất luận giải", fg=C["ok"])

        except Exception as e:
            messagebox.showerror("Lỗi phân tích", f"Quá trình phân tích gặp lỗi:\n{str(e)}")
            self.status_label.config(text="✗ Quá trình gián đoạn", fg=C["err"])
    def clear_all(self):
        if self.is_camera_running:
            self.stop_camera()

        self.current_image = None
        self.image_label.config(
            image="", text="✧\n\nXin mời cung cấp hình ảnh\nbàn tay cần xem bói",
            width=DISPLAY_W // 10, height=DISPLAY_H // 18,
        )
        self.image_info.config(text="")

        for f in [self.sinh_frame, self.tam_frame, self.tri_frame]:
            f.result_label.config(text="—")
            f.meaning_label.config(text="")
            
        self.conclusion_label.config(text="Đang chờ hình ảnh bàn tay để xem bói...")

        self.analyze_btn.config(state="disabled")
        self.status_label.config(text="✧ Đã dọn dẹp, sẵn sàng xem ảnh mới", fg=C["text_mid"])

    def on_closing(self):
        if self.is_camera_running:
            self.stop_camera()
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app  = PalmistryApp(root)
    root.protocol("WM_DELETE_WINDOW", app.on_closing)
    root.mainloop()
