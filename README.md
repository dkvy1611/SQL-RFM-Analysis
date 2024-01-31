# RFM segmentation
## Sơ lược về phân tích RFM

Phân tích RFM (Recency, Frequency, Monetary) là một phương pháp phân loại khách hàng dựa trên ba yếu tố chính: Recency, Frequency và Monetary. Phương pháp này thường được sử dụng trong lĩnh vực quản lý khách hàng và tiếp thị để hiểu rõ hơn về giá trị và hành vi mua sắm của khách hàng.

Ba yếu tố chính của phân tích RFM:

1. **Recency (R):**
   - Đánh giá mức độ gần đây của khách hàng đã thực hiện giao dịch.
   - Thường được đo bằng khoảng thời gian từ lần mua gần nhất của khách hàng.

2. **Frequency (F):**
   - Đo lường số lần mua sắm của khách hàng trong một khoảng thời gian cụ thể.
   - Giúp xác định mức độ trung thành và tính thường xuyên của khách hàng.

3. **Monetary (M):**
   - Đo lường giá trị tổng cộng của các giao dịch mà khách hàng đã thực hiện trong một khoảng thời gian.
   - Cho biết giá trị đóng góp của khách hàng cho doanh nghiệp.

Các bước thực hiện phân tích RFM thường bao gồm:
   - **Thu thập dữ liệu:** Lấy dữ liệu về lịch sử giao dịch của khách hàng, bao gồm thời điểm gần đây nhất, tần suất mua sắm và giá trị giao dịch.
   - **Chuẩn hóa dữ liệu:** Đảm bảo rằng các dữ liệu RFM được chuẩn hóa để có thể so sánh và tính toán dễ dàng.
   - **Phân loại khách hàng:** Sử dụng các ngưỡng hoặc phương pháp khác nhau để phân loại khách hàng thành các nhóm dựa trên các giá trị RFM.
   - **Xác định chiến lược:** Dựa trên nhóm RFM, doanh nghiệp có thể xác định chiến lược tiếp thị và quản lý khách hàng phù hợp cho từng nhóm.

Phân tích RFM giúp doanh nghiệp tập trung chiến lược tiếp thị và dịch vụ vào từng nhóm khách hàng cụ thể, tối ưu hóa chăm sóc khách hàng và tăng cường giữ chân, doanh thu và lợi nhuận.

## Về project: 
1. Tạo database "Project" và bảng "Segment Score"

2. Data Cleaning

3. Adhoc Tasks và phân tích RFM
- Doanh thu theo từng ProductLine, Year  và DealSize?
- Đâu là tháng có bán tốt nhất mỗi năm?

- Product line nào được bán nhiều ở tháng 11?

- Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
Xếp hạng các các doanh thu đó theo từng năm.

- Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
