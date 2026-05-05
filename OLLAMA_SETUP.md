# Hướng dẫn thiết lập AI Tutor (Ollama)

Để tính năng AI Tutor hoạt động trên thiết bị di động hoặc máy ảo (emulator), bạn cần cấu hình Ollama trên máy tính để cho phép kết nối từ bên ngoài.

## 1. Xác định IP của máy tính
Mở Terminal/PowerShell và chạy lệnh:
```powershell
ipconfig
```
Tìm dòng `IPv4 Address` (thường là `192.168.x.x`).

## 2. Cấu hình .env
Mở file `.env` trong project và cập nhật:
```env
OLLAMA_BASE_URL=http://<IP_CỦA_BẠN>:11434
OLLAMA_MODEL=llama3.2
```

## 3. Khởi động Ollama với Host 0.0.0.0
Mặc định Ollama chỉ lắng nghe tại `localhost` (127.0.0.1). Bạn cần ép nó lắng nghe trên toàn bộ giao diện mạng để điện thoại có thể kết nối.

### Trên Windows (PowerShell):
1. **Quan trọng**: Ollama có thể đang chạy ngầm. Bạn cần tắt nó đi trước:
   - Chuột phải vào biểu tượng Ollama ở thanh Taskbar và chọn **Quit**.
   - Hoặc chạy lệnh này trong PowerShell:
     ```powershell
     Stop-Process -Name "ollama" -ErrorAction SilentlyContinue
     ```
2. Mở PowerShell và chạy:
   ```powershell
   $env:OLLAMA_HOST="0.0.0.0"
   ollama serve
   ```

### Kiểm tra kết nối:
Dùng điện thoại hoặc máy ảo truy cập vào địa chỉ `http://<IP_CỦA_BẠN>:11434` qua trình duyệt. Nếu thấy thông báo "Ollama is running", nghĩa là đã thành công.

## 4. Tải Model
Đảm bảo bạn đã tải model đã cấu hình trong `.env`:
```powershell
ollama pull llama3.2:1b
```

## Lỗi thường gặp
- **Connection refused**: Do Ollama chưa chạy hoặc chưa set `OLLAMA_HOST=0.0.0.0`.
- **Timeout**: Do tường lửa (Firewall) trên Windows chặn cổng 11434. Bạn có thể cần thêm quy tắc cho phép cổng này trong Windows Firewall.
