**1. Pencarian Data Melalui Request GET pada POSTMAN**
<img src="./Search-1.jpeg" width="600"/>

Gambar ini menunjukkan proses penggunaan Postman untuk mengirim request GET ke endpoint http://localhost:8000/api/products yang berada di server lokal dengan tujuan untuk mengambil daftar produk dari sistem berbasis API.  Setelah request dikirim, server merespons dengan status 200 OK, yang menandakan bahwa permintaan berhasil diproses. Namun, bagian data dalam response menunjukkan array kosong ("data": []), yang mengindikasikan bahwa saat ini belum ada produk yang tersimpan di database. Pesan "Successfully loaded all the products." mengonfirmasi bahwa tidak ada kesalahan pada API, melainkan hanya belum ada entri data yang dapat ditampilkan dari sistem. Proses ini adalah langkah awal dalam pengujian API sebelum menambahkan data menggunakan metode lain seperti POST.

**2. Penambahan Data Melalui Request ADD pada POSTMAN**
<img src="./Add-1.jpeg" width="600"/>

Gambar ini memperlihatkan proses pengujian API menggunakan Postman dengan metode POST ke endpoint http://localhost:8000/api/products untuk menambahkan produk baru ke dalam sistem. Di tab Body, user memilih format raw dengan tipe data JSON, lalu mengisi data produk berupa nama ("Ayam Geprek"), harga (20000), URL gambar ("https://example.com/ayamgeprek.jpg"), dan status promo (true). Setelah menekan tombol Send, server memberikan respon 201 Created, yang menandakan bahwa produk berhasil ditambahkan ke database. Response body menampilkan detail produk yang baru saja disimpan, termasuk field tambahan yang dihasilkan otomatis oleh sistem seperti id, created_at, dan updated_at. Proses ini menunjukkan bagaimana client dapat berinteraksi dengan API untuk melakukan operasi Create, serta memberikan bukti bahwa endpoint berfungsi dengan baik untuk menyimpan data ke dalam sistem.

**3. Pencarian Hasil Penambahan Data Melalui Request GET pada POSTMAN**
<img src="./Search-2.jpeg" width="600"/>

Gambar ini menunjukkan penggunaan Postman untuk mengakses data produk secara spesifik melalui metode GET ke endpoint http://localhost:8000/api/products/1. Endpoint ini ditujukan untuk mengambil detail dari produk dengan ID tertentu, dalam hal ini ID = 1. Setelah request dikirim, server memberikan response 200 OK yang menandakan bahwa data berhasil ditemukan. Response body berisi pesan "Successfully loaded the product." beserta detail produk seperti name, price, photo, dan is_promo, serta timestamp created_at dan updated_at. Ini menunjukkan bahwa data yang sebelumnya ditambahkan berhasil disimpan dan dapat diakses kembali dengan menggunakan ID uniknya, membuktikan bahwa fitur read-by-ID pada API bekerja dengan baik.

**4. Pengeditan Data Melalui Request PUT pada POSTMAN**
<img src="./Edit-1.jpeg" width="600"/>

Gambar ini menampilkan penggunaan metode PUT melalui Postman ke endpoint http://localhost:8000/api/products/1, yang digunakan untuk memperbarui data produk dengan ID = 1. Data yang dikirimkan di body berisi informasi baru, yaitu: "name" diubah menjadi "Ayam Kremes", "price" diubah menjadi 21000, "photo" dan "is_promo" tetap sama. Setelah request dikirim, server merespon dengan status 200 OK dan pesan "Successfully updated the product.", menandakan bahwa pembaruan data berhasil dilakukan. Data yang ditampilkan di response memperlihatkan nilai-nilai terbaru dari produk, termasuk waktu update (updated_at) yang berubah menyesuaikan dengan waktu modifikasi. Ini membuktikan bahwa fitur update data produk pada API bekerja dengan baik dan memungkinkan perubahan informasi secara spesifik menggunakan ID produk.

**5. Penghapusan Data Melalui DELETE pada POSTMAN**
<img src="./Delete-1.jpeg" width="600"/>

Gambar ini menunjukkan proses menghapus data produk menggunakan metode DELETE di Postman ke endpoint http://localhost:8000/api/products/1. Permintaan ini ditujukan untuk menghapus produk dengan ID = 1, yang sebelumnya memiliki nama "Ayam Kremes". Walaupun terdapat data JSON di bagian Body, sebenarnya tidak dibutuhkan dalam permintaan DELETE karena yang diperlukan hanyalah ID produk pada URL. Setelah permintaan dikirim, server memberikan respons dengan status 200 OK dan pesan "Successfully deleted the product.", yang menandakan bahwa proses penghapusan berhasil. Hal ini membuktikan bahwa fitur delete product pada API bekerja dengan baik dan dapat menghapus data secara permanen dari database berdasarkan ID yang ditentukan.
