# 📖 FAQ — `ddcutil` Setup & Penggunaan

> **`ddcutil`** adalah tool Linux untuk mengontrol pengaturan monitor (brightness, contrast, input source) menggunakan protokol **DDC/CI** melalui koneksi **I²C**.

---

## 🛠️ Instalasi

| OS / Distro         | Perintah Instalasi         |
| ------------------- | -------------------------- |
| **Arch / Manjaro**  | `sudo pacman -S ddcutil`   |
| **Debian / Ubuntu** | `sudo apt install ddcutil` |

---

## ⚙️ Setup Awal

### 1️⃣ Load modul kernel `i2c-dev`

```bash
sudo modprobe i2c-dev
```

Agar otomatis aktif setiap boot:

```bash
echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf
```

---

### 2️⃣ Tambahkan user ke grup `i2c`

```bash
sudo gpasswd -a $USER i2c
```

Lalu **logout → login ulang** agar berlaku.

---

### 3️⃣ Aktifkan DDC/CI di monitor

* Buka menu OSD monitor (pakai tombol fisik monitor)
* Cari opsi **DDC/CI**
* Pastikan **Enabled**

---

## 🔍 Verifikasi

### Cek monitor yang terdeteksi

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

### Cek brightness

```bash
ddcutil getvcp 10
```

Output:

```
VCP code 0x10 (Brightness): current value = 40, max value = 100
```

---

## 💡 Mengubah Brightness

| Perintah               | Fungsi                         |                                        |                   |                                                    |
| ---------------------- | ------------------------------ | -------------------------------------- | ----------------- | -------------------------------------------------- |
| `ddcutil setvcp 10 70` | Set brightness ke 70%          |                                        |                   |                                                    |
| `ddcutil getvcp 10`    | Lihat brightness sekarang      |                                        |                   |                                                    |
| Script **+10%**        | \`current=\$(ddcutil getvcp 10 | awk -F'current value = ' '{print \$2}' | awk '{print \$1}' | tr -d ','); ddcutil setvcp 10 \$((current + 10))\` |
| Script **-10%**        | \`current=\$(ddcutil getvcp 10 | awk -F'current value = ' '{print \$2}' | awk '{print \$1}' | tr -d ','); ddcutil setvcp 10 \$((current - 10))\` |

---

## 🎛️ Integrasi dengan Waybar

**Config JSONC Waybar**

```jsonc
"custom/backlight": {
    "interval": 1,
    "exec": "~/.config/waybar/scripts/custom/ddc-brightness get",
    "on-scroll-up": "~/.config/waybar/scripts/custom/ddc-brightness up",
    "on-scroll-down": "~/.config/waybar/scripts/custom/ddc-brightness down",
    "format": "󰃠 {}%"
}
```

**Script `~/.config/waybar/scripts/custom/ddc-brightness`**

> Contoh script bisa dilihat di bagian repo ini untuk kontrol brightness secara cepat dan menampilkan notifikasi.

---

## 🚑 Troubleshooting

| Masalah                                                       | Solusi                                                              |
| ------------------------------------------------------------- | ------------------------------------------------------------------- |
| `No /dev/i2c devices exist. ddcutil requires module i2c-dev.` | Load modul: `sudo modprobe i2c-dev`                                 |
| Nilai brightness tidak berubah                                | Pastikan DDC/CI aktif di monitor                                    |
| Tidak bekerja di port tertentu                                | Coba ganti kabel (HDMI/DP), beberapa adapter tidak mendukung DDC/CI |
| Delay saat scroll                                             | Gunakan sistem **cache** di script agar lebih responsif             |

---

## 📌 Catatan

* `ddcutil` tidak selalu bekerja pada monitor via docking station atau adapter murah.
* Gunakan interval pembacaan ≥ 0.1 detik untuk menghindari penolakan perintah oleh monitor.
* Beberapa monitor menyimpan setting brightness terpisah untuk setiap input (HDMI 1, HDMI 2, DP).
