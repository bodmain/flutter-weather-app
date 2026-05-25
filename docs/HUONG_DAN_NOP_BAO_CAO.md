# Hướng dẫn nộp báo cáo (30–60 trang)

## Bước 1: Xuất sang Word

1. Mở `docs/BAO_CAO_BAI_TAP_LON.md` trong VS Code hoặc copy vào Google Docs.
2. Định dạng theo quy chế trường (thường: Times New Roman 13, giãn dòng 1.5, thụt đầu dòng 1cm).
3. Tạo **bìa** riêng (không tính vào 30–60 trang).
4. Tạo **mục lục tự động** trong Word (References → Table of Contents).

## Bước 2: Bổ sung nội dung bắt buộc để đủ trang

| Nội dung cần chèn | Gợi ý số trang |
|-------------------|----------------|
| Ảnh mockup `weather_app_mockup.drawio.png` | 1–2 |
| Screenshot 3 màn hình + chi tiết Home | 4–6 |
| Screenshot cảnh báo / notification trên máy thật | 2–3 |
| Screenshot trợ lý AI (hỏi + trả lời) | 2 |
| Bảng test case đã điền Pass/Fail + ảnh minh chứng | 3–5 |
| Trích PDF backend (sơ đồ, ERD nếu có) | 5–10 |
| Mã nguồn dài hơn trong Phụ lục | 3–5 |

**Mục tiêu:** Sau khi chèn hình, nội dung chính (Mở đầu → Kết luận) khoảng **35–45 trang** là an toàn.

## Bước 3: Điền placeholder

Tìm và thay tất cả `[ĐIỀN THÔNG TIN]`, `[ĐIỀN]`, `[MSSV]` trong file báo cáo.

## Bước 4: Phụ lục & Tài liệu tham khảo

- Đặt **Phụ lục** và **Tài liệu tham khảo** sau Kết luận (không tính vào 30–60 trang theo đề bài).
- Link GitHub: https://github.com/bodmain/flutter-weather-app

## Bước 5: Kiểm tra trước khi nộp

- [ ] Đủ các chương theo đề: Mở đầu, Chương 1–3, Kết luận
- [ ] Có phân công nhóm chi tiết
- [ ] Có sơ đồ (kiến trúc, sequence, use case)
- [ ] Có bảng kiểm thử đã điền kết quả
- [ ] Link mã nguồn trong Phụ lục
- [ ] Không để API key thật trong báo cáo in (chỉ mô tả cách cấu hình)
