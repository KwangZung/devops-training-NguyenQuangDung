# Báo cáo Lý thuyết Day 4 - Storage: PV, PVC, StorageClass

## 1. Vì sao cần Storage trong Kubernetes?

Filesystem bên trong Container mang tính tạm thời (ephemeral) — khi Container bị xóa hoặc crash, toàn bộ dữ liệu ghi trong quá trình chạy sẽ mất theo. Đây là hành vi bình thường với ứng dụng stateless, nhưng với các ứng dụng stateful như database, dữ liệu phải được lưu giữ lâu dài và độc lập với vòng đời của Container.

Kubernetes giải quyết bài toán này bằng hệ thống lưu trữ gồm ba tầng: Volume, PersistentVolume (PV) và PersistentVolumeClaim (PVC).

---

## 2. Volume

Volume là đơn vị lưu trữ được gắn với Pod, cho phép các Container trong Pod chia sẻ dữ liệu và duy trì dữ liệu qua các lần Container khởi động lại. Vòng đời của Volume gắn với Pod, không phải Container — khi Pod bị xóa, Volume cũng bị xóa (tùy loại).

Để sử dụng Volume, cần khai báo ở hai nơi trong YAML của Pod:

```yaml
spec:
  volumes:
    - name: my-vol
      emptyDir: {}          # khai báo Volume ở cấp Pod
  containers:
    - name: app
      image: nginx
      volumeMounts:
        - name: my-vol
          mountPath: /data  # mount vào Container tại đường dẫn cụ thể
```

Các loại Volume phổ biến:

| Loại | Mô tả |
|---|---|
| `emptyDir` | Folder trống, tồn tại trong vòng đời Pod. Dùng để chia sẻ dữ liệu tạm thời giữa các Container. |
| `hostPath` | Mount đường dẫn từ filesystem Node vào Pod. Dữ liệu còn sau khi Pod bị xóa, nhưng Pod bị ràng buộc vào Node cụ thể. Không khuyến nghị trong production. |
| `configMap` / `secret` | Inject cấu hình hoặc dữ liệu nhạy cảm vào Container dưới dạng file. |
| `persistentVolumeClaim` | Cách tiêu chuẩn để dùng lưu trữ lâu dài thông qua hệ thống PV/PVC. |

---

## 3. PersistentVolume (PV)

PV là một tài nguyên lưu trữ vật lý trong Cluster, được tạo thủ công bởi quản trị viên (Static Provisioning) hoặc tự động bởi hệ thống (Dynamic Provisioning). PV là tài nguyên ở cấp Cluster (không thuộc Namespace nào) và có vòng đời độc lập với Pod.

Các thuộc tính quan trọng của PV:

| Thuộc tính | Các giá trị / Mô tả |
|---|---|
| `capacity.storage` | Dung lượng lưu trữ, ví dụ `5Gi` |
| `accessModes` | `ReadWriteOnce` (1 Node đọc/ghi), `ReadOnlyMany` (nhiều Node đọc), `ReadWriteMany` (nhiều Node đọc/ghi) |
| `persistentVolumeReclaimPolicy` | `Retain` (giữ nguyên khi PVC bị xóa), `Delete` (xóa cả PV và dữ liệu vật lý) |
| `volumeMode` | `Filesystem` (mặc định) hoặc `Block` (raw block device) |

Vòng đời của PV: `Available` → `Bound` (khi bind với PVC) → `Released` (khi PVC bị xóa) → `Failed` (lỗi thu hồi).

---

## 4. PersistentVolumeClaim (PVC)

PVC là yêu cầu lưu trữ do người dùng hoặc ứng dụng tạo ra. Kubernetes tự động tìm và bind PVC với PV thỏa mãn các điều kiện về dung lượng, access mode và storageClassName. Quan hệ bind là một-một.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Sau khi bind thành công, Pod sử dụng PVC thông qua loại Volume `persistentVolumeClaim`:

```yaml
volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: my-pvc
containers:
  - name: app
    volumeMounts:
      - name: storage
        mountPath: /data
```

Dữ liệu ghi vào `/data` được ánh xạ xuống PV vật lý và tồn tại lâu dài bất kể Pod bị xóa hay khởi động lại.

---

## 5. Static Provisioning và Dynamic Provisioning

| | Static Provisioning | Dynamic Provisioning |
|---|---|---|
| Cách tạo PV | Quản trị viên tạo thủ công trước | Hệ thống tự động tạo khi có PVC |
| Yêu cầu | Khai báo `kind: PersistentVolume` | Khai báo StorageClass với Provisioner hợp lệ |
| Phù hợp với | Môi trường học tập, Cluster nhỏ | Môi trường production, Cloud |
| Hạn chế | Quản trị viên phải dự đoán trước nhu cầu | Cần Provisioner được cài đặt và cấu hình đúng |

---

## 6. StorageClass

StorageClass mô tả một hạng lưu trữ mà Cluster cung cấp (ví dụ: `fast-ssd`, `standard`). Mỗi StorageClass ánh xạ đến một Provisioner, là thành phần thực hiện việc tạo PV vật lý khi có PVC yêu cầu.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: rancher.io/local-path   # không thể thay đổi sau khi tạo
reclaimPolicy: Delete                # Delete hoặc Retain
volumeBindingMode: WaitForFirstConsumer
```

Trường `volumeBindingMode` xác định thời điểm PV được tạo:
- `Immediate`: tạo PV ngay khi PVC được tạo.
- `WaitForFirstConsumer`: trì hoãn đến khi có Pod thực sự dùng PVC, đảm bảo PV được tạo trên cùng Node với Pod.

Khi PVC không chỉ định `storageClassName`, hệ thống sẽ dùng StorageClass mặc định của Cluster (đánh dấu bằng annotation `storageclass.kubernetes.io/is-default-class: "true"`). Trong môi trường k3d, StorageClass mặc định là `local-path` với Provisioner `rancher.io/local-path`, lưu dữ liệu tại `/var/lib/rancher/k3s/storage/` trên Node.

## 7. Rancher- Monitor Cluster qua giao diện web

Rancher là một nền tảng quản lý Kubernetes đa Cluster mã nguồn mở. Rancher cung cấp giao diện web tập trung để theo dõi và quản lý toàn bộ tài nguyên trong Cluster như Node, Pod, Deployment, Service, Namespace, PV, PVC, ConfigMap, Secret... mà không cần phải nhớ lệnh `kubectl`.

Trong môi trường thực tế, Rancher được sử dụng để:
- Monitor trạng thái và tài nguyên của nhiều Cluster từ một điểm duy nhất.
- Phân quyền truy cập cho từng thành viên trong team theo từng Namespace hay Cluster.
- Triển khai ứng dụng và quản lý Helm chart thông qua giao diện đồ họa.
