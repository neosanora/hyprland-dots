# 📖 FAQ — `ddcutil` Setup & Penggunaan

## ❓ Apa itu `ddcutil`?

`ddcutil` adalah tool di Linux untuk mengontrol pengaturan monitor (seperti brightness, contrast, input source) menggunakan protokol **DDC/CI** melalui koneksi **I²C**.

---

## 🔹 Instalasi

### **Arch Linux / Manjaro**

```bash
sudo pacman -S ddcutil
```

### **Debian / Ubuntu**

```bash
sudo apt install ddcutil
```

---

## 🔹 Setup Awal

1. **Load modul kernel `i2c-dev`**

```bash
sudo modprobe i2c-dev
```

Agar otomatis aktif setiap boot:

```bash
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf
```

2. **Tambahkan user ke grup `i2c`**

```bash
sudo gpasswd -a $USER i2c
```

Lalu logout → login ulang.

3. **Aktifkan DDC/CI di monitor**

* Masuk ke **OSD menu** monitor (pakai tombol fisik monitor)
* Cari opsi **DDC/CI**
* Pastikan **Enabled**

---

## 🔹 Verifikasi Monitor

1. Deteksi monitor:

```bash
ddcutil detect
```

Contoh output:

```
Display 1
   I2C bus: /dev/i2c-6
   Model:  DELL U2414H
   Serial: ABC123XYZ
   MCCS version: 2.1
```

2. Cek brightness:

```bash
ddcutil getvcp 10
```

Output:

```
VCP code 0x10 (Brightness): current value = 40, max value = 100
```

---

## 🔹 Mengubah Brightness

* Set ke **nilai tertentu**:

```bash
ddcutil setvcp 10 70
```

* Naikkan 10 poin:

```bash
current=$(ddcutil getvcp 10 | awk -F'current value = ' '{print $2}' | awk '{print $1}' | tr -d ',')
ddcutil setvcp 10 $((current + 10))
```

* Turunkan 10 poin:

```bash
current=$(ddcutil getvcp 10 | awk -F'current value = ' '{print $2}' | awk '{print $1}' | tr -d ',')
ddcutil setvcp 10 $((current - 10))
```

---

## 🔹 Integrasi dengan Waybar (Contoh)

```jsonc
"custom/backlight": {
    "interval": 1,
    "exec": "~/.config/waybar/scripts/custom/ddc-brightness get",
    "on-scroll-up": "~/.config/waybar/scripts/custom/ddc-brightness up",
    "on-scroll-down": "~/.config/waybar/scripts/custom/ddc-brightness down",
    "format": "󰃠 {}%"
}
```

Script `~/.config/waybar/scripts/custom/ddc-brightness` bisa dibuat untuk memanggil `ddcutil` sesuai kebutuhan (lihat contoh di repo).

---

## ❗ Troubleshooting

* **Pesan error:**

  ```
  No /dev/i2c devices exist.
  ddcutil requires module i2c-dev.
  ```

  → Load modul kernel `i2c-dev`:

  ```bash
  sudo modprobe i2c-dev
  ```

* **Tidak ada perubahan saat ubah brightness:**

  * Pastikan **DDC/CI** aktif di monitor
  * Gunakan kabel yang mendukung DDC/CI (HDMI/DP, bukan converter murah)
  * Beberapa monitor hanya mendukung brightness lewat HDMI/DP, bukan USB-C

---

## 📌 Catatan

* `ddcutil` mungkin tidak bekerja di monitor yang terkoneksi lewat docking station murah atau adaptor tertentu.
* Jangan spam perintah `ddcutil` terlalu cepat (kurang dari 0.1s) karena monitor bisa menolak perintah.
* Untuk kontrol lebih halus dan responsif, gunakan **cache** di script lalu update monitor di background.

---

Kalau kamu mau, aku bisa sekalian bikin **versi Markdown ini** jadi **lebih rapi dengan icon dan tabel** supaya cocok jadi dokumentasi GitHub modern.
Kamu mau aku buatin juga?
