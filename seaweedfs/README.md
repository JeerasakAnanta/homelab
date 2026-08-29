## เริ่มใช้งานครั้งแรก

```bash
cp .env.example .env          # ปรับ port / limit ตามต้องการ
cp s3.json.example s3.json    # ใส่ accessKey / secretKey จริง (ไฟล์นี้ถูก gitignore)
docker compose up -d
docker compose ps             # รอจน service ทั้งหมดขึ้นสถานะ healthy
```

service มี healthcheck และ `depends_on: condition: service_healthy` แล้ว
ดังนั้น `volume` / `filer` / `s3` จะรอ dependency พร้อมก่อนค่อยสตาร์ท

---

หลังจากรัน `docker compose up -d` แล้ว เข้าใช้งานแต่ละ service ได้ที่:

| Service | URL | ใช้ทำอะไร |
|---|---|---|
| **Master UI** | `http://<host-ip>:${MASTER_PORT}` (เช่น `http://localhost:9333`) | ดูสถานะ cluster, volume servers, topology |
| **Volume** | `http://<host-ip>:${VOLUME_PORT}` | ปกติไม่ต้องเข้าตรงๆ เว้นแต่ debug |
| **Filer UI** | `http://<host-ip>:${FILER_PORT}` (เช่น `http://localhost:8888`) | เข้าดู/อัปโหลดไฟล์ผ่าน web UI แบบ file browser |
| **S3 API** | `http://<host-ip>:${S3_PORT}` (เช่น `http://localhost:8333`) | ใช้กับ S3 client (aws-cli, rclone, MinIO client, SDK) |

**ตัวอย่างการเข้าใช้งาน:**

1. **เช็คว่า cluster ทำงานปกติ**

```bash
curl http://localhost:9333/cluster/status
```

1. **เปิด Filer web UI ผ่าน browser**

```
http://localhost:8888
```

จะเห็นหน้า file browser ให้ upload/download ไฟล์ได้เลย

1. **ใช้งานผ่าน S3 API** (ต้องมี access/secret key ตรงกับใน `s3.json`)

```bash
aws s3 --endpoint-url http://localhost:8333 ls
aws s3 --endpoint-url http://localhost:8333 cp myfile.txt s3://mybucket/
```

ต้อง config `aws configure` หรือ export `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` ให้ตรงกับใน `s3.json` ก่อน

1. **Mount เป็น filesystem (FUSE)** — ถ้าต้องการ mount เหมือน disk

```bash
weed mount -filer=localhost:8888 -dir=/mnt/seaweedfs
```

