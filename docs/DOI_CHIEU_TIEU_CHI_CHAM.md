# Đối chiếu phiếu chấm — BTL có vấn đáp (6 điểm + 1 hình thức)

Dùng checklist này **trước khi nộp Elearning** để tự chấm và tránh mất điểm 0,5.

---

## Tiêu chí 1 — Hình thức (1,0 điểm)

| Yêu cầu | Có trong báo cáo? | Gợi ý |
|---------|-------------------|--------|
| Mở đầu: môn học, đề tài, nhóm & phân công | ☐ | `BAO_CAO` — Mở đầu |
| Chương 1 — Cơ sở lý thuyết | ☐ | Chương 1 |
| Chương 2 — Xây dựng ứng dụng | ☐ | Chương 2 |
| Chương 3 — Thực nghiệm | ☐ | Chương 3 |
| Kết luận: đạt được + cải tiến | ☐ | Kết luận |
| Phụ lục + Tài liệu tham khảo (riêng, không tính 30–60 trang) | ☐ | Cuối file |
| 30–60 trang nội dung chính | ☐ | Chèn ảnh + PDF backend |
| Giải thích rõ, không chỉ liệt kê | ☐ | Mỗi sơ đồ có 1–2 đoạn giải thích |

**Tự chấm:** Đủ ☐ → **1,0** | Thiếu chi tiết → **0,5** | Sai/thiếu chương → **0**

---

## Tiêu chí 2.1 — Lý thuyết, PP, thư viện, công cụ (1,0 điểm)

| Nội dung bắt buộc | Mục báo cáo |
|-------------------|-------------|
| Flutter / Dart đa nền tảng | §1.1 |
| Kiến trúc MVVM / 3 lớp | §1.2 |
| REST + package `http` | §1.3 |
| GetX state management | §1.4 |
| SharedPreferences | §1.5 |
| Local notifications | §1.6 |
| Gemini / Generative AI | §1.7 |
| UI/UX (glass, theme) | §1.8 |
| **Bảng công cụ:** Android Studio, Git, Xcode… | **§1.10** |
| Phương pháp: iterative / top-down | §1.10 |

**Câu hỏi vấn đáp hay gặp:** *Vì sao chọn GetX thay vì Bloc?* — Nhẹ, ít boilerplate, phù hợp quy mô BTL.

---

## Tiêu chí 2.2 — Chức năng, phân hệ, nền tảng (1,0 điểm)

| Nội dung bắt buộc | Mục báo cáo |
|-------------------|-------------|
| Mô tả từng chức năng đề bài | §2.1 |
| Use case, actor | §2.2 |
| **Bảng phân hệ P1–P4** (Mobile, API, Backend tương lai) | **§2.6.1** |
| **Bảng đối chiếu đề mã đề 36** | **§2.6.2** |
| Nền tảng: Android, iOS (+ Web/Desktop khả năng Flutter) | **§2.6.3** |

**Lưu ý:** Đề yêu cầu nói **web, mobile, desktop** — phải ghi rõ: *triển khai chính mobile*; Flutter *có thể* build web/desktop.

---

## Tiêu chí 2.3 — Kiến trúc, thiết kế lớp, UI/UX, triển khai (1,0 điểm)

| Nội dung bắt buộc | Mục báo cáo |
|-------------------|-------------|
| Kiến trúc **3 tầng / 3 lớp** + sơ đồ | **§2.7.1** |
| Bảng **thiết kế lớp** (Model, Service, Controller, View) | **§2.7.2–2.7.3** |
| UI/UX Android vs iOS | **§2.8** |
| Mockup | §2.8.4 + file PNG |
| Mô hình triển khai: **monolithic** client | **§2.9** |
| Kiến trúc tổng thể (Chương 3) | §3.1 |

---

## Tiêu chí 2.4 — Mô hình dữ liệu & lưu trữ (1,0 điểm)

| Nội dung bắt buộc | Mục báo cáo |
|-------------------|-------------|
| Sơ đồ ER / conceptual | **§2.10.1** |
| Ánh xạ JSON API → class | **§2.10.2** |
| SharedPreferences: key, cấu trúc | **§2.10.3** |
| So sánh lưu trữ Android / iOS / Web / Desktop | **§2.10.4** |
| Dữ liệu chỉ lưu RAM | **§2.10.5** |

---

## Tiêu chí 2.5 — Kiểm thử (1,0 điểm)

| Nội dung bắt buộc | Mục báo cáo |
|-------------------|-------------|
| Mục tiêu + môi trường test | §3.3.1–3.3.2 |
| Bảng test **chức năng** (TC01–TC12) — **điền Pass/Fail** | §3.3.3 |
| Test **Android** riêng (TP-Axx) | **§3.3.7** |
| Test **iOS** riêng (TP-Ixx) | **§3.3.7** |
| Test **phi chức năng** (NFR01–06) | **§3.3.8** |
| Ảnh minh chứng | Chèn vào Word |

**Không để trống cột "Kết quả thực tế"** — giảng viên trừ điểm "chưa đủ chi tiết".

---

## Gợi ý vấn đáp (5–10 phút)

1. Vẽ miệng kiến trúc 3 lớp và luồng từ Search → API → Home.
2. Giải thích khi nào gửi notification mưa (`WeatherController._checkAndNotify`).
3. So sánh monolithic vs microservice trong dự án này.
4. Vì sao dùng SharedPreferences thay vì SQLite?
5. Demo trên máy: tìm thành phố, bật cảnh báo, hỏi AI.

---

## File liên quan

- Báo cáo đầy đủ: [`BAO_CAO_BAI_TAP_LON.md`](./BAO_CAO_BAI_TAP_LON.md)
- Hướng dẫn đủ trang: [`HUONG_DAN_NOP_BAO_CAO.md`](./HUONG_DAN_NOP_BAO_CAO.md)
