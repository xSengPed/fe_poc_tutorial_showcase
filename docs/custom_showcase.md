# Custom Showcase

ระบบ Tutorial Overlay แบบ Chat Balloon สำหรับ Flutter สร้างขึ้นเพื่อใช้ภายในโปรเจกต์นี้โดยไม่ต้องพึ่งพา Package ภายนอก

**ไฟล์หลัก:** `lib/ui/widgets/tutorial_showcase/custom_showcase.dart`

---

## สรุป Components

| Class | ประเภท | หน้าที่ |
|---|---|---|
| `ShowcasePlacement` | `enum` | กำหนดตำแหน่ง Balloon relative กับ Target |
| `ShowcaseStep` | `class` | Data model ของแต่ละ Tutorial Step |
| `ShowcaseController` | `ChangeNotifier` | ควบคุม State และ Lifecycle ของ Tutorial |
| `CustomShowcase` | `StatelessWidget` | Wrapper ที่ลงทะเบียน Widget เป็น Tutorial Target |

---

## ShowcasePlacement

กำหนดว่า Balloon จะแสดงอยู่ที่ตำแหน่งใดเทียบกับ Target Widget โดย Tail ของ Balloon จะชี้ไปหา Target เสมอ

```dart
enum ShowcasePlacement { above, below, leftOf, rightOf }
```

| Value | ความหมาย | Tail ชี้ไปทาง |
|---|---|---|
| `above` | Balloon อยู่เหนือ Target | ลงล่าง (ขอบล่างของ Balloon) |
| `below` | Balloon อยู่ใต้ Target | ขึ้นบน (ขอบบนของ Balloon) |
| `leftOf` | Balloon อยู่ซ้ายของ Target | ขวา (ขอบขวาของ Balloon) |
| `rightOf` | Balloon อยู่ขวาของ Target | ซ้าย (ขอบซ้ายของ Balloon) |

> ระบบจะ Auto-detect พื้นที่ว่างบนหน้าจอ หากพื้นที่ตาม `preferredPlacement` ไม่เพียงพอ (< 160px) จะ Fallback ไปยังทิศทางตรงข้ามโดยอัตโนมัติ

---

## ShowcaseStep

Data class สำหรับกำหนดข้อมูลของแต่ละ Tutorial Step

```dart
ShowcaseStep({
  required String title,
  required String description,
  ShowcasePlacement placement = ShowcasePlacement.below,
  double tailSize = 16.0,
})
```

### Parameters

| Parameter | Type | Default | คำอธิบาย |
|---|---|---|---|
| `title` | `String` | required | หัวข้อที่แสดงใน Balloon |
| `description` | `String` | required | คำอธิบายที่แสดงใน Balloon (max 3 บรรทัด) |
| `placement` | `ShowcasePlacement` | `below` | ตำแหน่ง Balloon ที่ต้องการ |
| `tailSize` | `double` | `16.0` | ขนาด (ฐาน) ของหางสามเหลี่ยม เป็น px |

### ตัวอย่างการปรับ tailSize

```dart
// หางขนาดเล็ก (subtle)
ShowcaseStep(title: '...', description: '...', tailSize: 10)

// หางขนาดปกติ (default)
ShowcaseStep(title: '...', description: '...')

// หางขนาดใหญ่ (เด่นชัด)
ShowcaseStep(title: '...', description: '...', tailSize: 28)
```

---

## ShowcaseController

ควบคุมการทำงานของ Tutorial ทั้งหมด สืบทอดจาก `ChangeNotifier`

```dart
final controller = ShowcaseController(steps: [...]);
```

### Methods

| Method | คำอธิบาย |
|---|---|
| `start(BuildContext context)` | เริ่ม Tutorial จาก Step แรก แทรก Overlay เข้าไปใน Widget Tree |
| `next()` | เลื่อนไปยัง Step ถัดไป หากเป็น Step สุดท้ายจะเรียก `close()` อัตโนมัติ |
| `close()` | ปิด Tutorial และลบ Overlay ออก |
| `dispose()` | เรียก `close()` แล้ว dispose controller (ควรเรียกใน `State.dispose()`) |

### Properties

| Property | Type | คำอธิบาย |
|---|---|---|
| `isActive` | `bool` | Tutorial กำลังแสดงอยู่หรือไม่ |
| `currentIndex` | `int` | Index ของ Step ปัจจุบัน (เริ่มจาก 0) |
| `totalSteps` | `int` | จำนวน Step ทั้งหมด |
| `isLastStep` | `bool` | Step ปัจจุบันเป็น Step สุดท้ายหรือไม่ |
| `currentStep` | `ShowcaseStep?` | Step ปัจจุบัน (null หากไม่ active) |

---

## CustomShowcase

Wrapper Widget ที่ลงทะเบียน Child Widget เป็น Target ของ Tutorial Step

```dart
CustomShowcase({
  required ShowcaseController controller,
  required int stepIndex,
  required Widget child,
})
```

### Parameters

| Parameter | Type | คำอธิบาย |
|---|---|---|
| `controller` | `ShowcaseController` | Controller ที่จัดการ Tutorial นี้ |
| `stepIndex` | `int` | Index ของ `ShowcaseStep` ที่ต้องการผูกกับ Widget นี้ |
| `child` | `Widget` | Widget ที่ต้องการให้ Tutorial ชี้ไปหา |

> `stepIndex` ต้องตรงกับ Index ของ `ShowcaseStep` ใน `ShowcaseController.steps`

---

## วิธีใช้งาน

### 1. สร้าง ShowcaseController พร้อม Steps

สร้างใน `initState` หรือเป็น `late final` field ของ `State` เพื่อให้ `GlobalKey` ภายใน `ShowcaseStep` มีอายุยืนตลอด lifecycle ของ Widget

```dart
class _MyPageState extends State<MyPage> {
  late final ShowcaseController _controller = ShowcaseController(
    steps: [
      ShowcaseStep(
        title: 'ปุ่มค้นหา',
        description: 'แตะที่นี่เพื่อค้นหาสิ่งที่ต้องการ',
        placement: ShowcasePlacement.below,
      ),
      ShowcaseStep(
        title: 'ปุ่มเพิ่ม',
        description: 'สร้างรายการใหม่ได้ที่นี่',
        placement: ShowcasePlacement.leftOf,
        tailSize: 20,
      ),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 2. ห่อ Widget ด้วย CustomShowcase

`stepIndex` ต้องตรงกับลำดับของ `ShowcaseStep` ในรายการ

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // stepIndex: 0 → ผูกกับ ShowcaseStep แรก
      CustomShowcase(
        controller: _controller,
        stepIndex: 0,
        child: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
      ),
      // stepIndex: 1 → ผูกกับ ShowcaseStep ที่สอง
      CustomShowcase(
        controller: _controller,
        stepIndex: 1,
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    ],
  );
}
```

### 3. เริ่ม Tutorial

```dart
ElevatedButton(
  onPressed: () => _controller.start(context),
  child: const Text('เริ่ม Tutorial'),
)
```

---

## UX Behavior

- **Backdrop:** พื้นหลังจะมืดลง (opacity 65%) และมีช่องสว่างตรง Target Widget
- **แตะ Backdrop:** ปิด Tutorial ทันที (เทียบเท่ากับการกดปุ่ม X)
- **ปุ่ม X:** ปิด Tutorial ทั้งหมด
- **ปุ่ม Next:** เลื่อนไปยัง Step ถัดไป
- **ปุ่ม Done:** แสดงเมื่อถึง Step สุดท้าย กดแล้วปิด Tutorial
- **Step Counter:** แสดง `ปัจจุบัน / ทั้งหมด` มุมล่างซ้ายของ Balloon

---

## การเพิ่ม Tutorial ใหม่

1. เพิ่ม `ShowcaseStep` เข้าไปในรายการ `steps` ของ Controller
2. ห่อ Widget เป้าหมายด้วย `CustomShowcase` พร้อมระบุ `stepIndex` ที่ถูกต้อง

```dart
// เพิ่ม Step ใหม่
ShowcaseStep(
  title: 'ฟีเจอร์ใหม่',
  description: 'คำอธิบายฟีเจอร์ใหม่ที่เพิ่มเข้ามา',
  placement: ShowcasePlacement.above,
)

// ห่อ Widget ใหม่
CustomShowcase(
  controller: _controller,
  stepIndex: 2, // ต้องตรงกับ index ในรายการ steps
  child: MyNewFeatureWidget(),
)
```

> **หมายเหตุ:** ลำดับของ `CustomShowcase.stepIndex` และ `ShowcaseStep` ในรายการต้องตรงกันเสมอ

---

## ข้อควรระวัง

- ต้องสร้าง `ShowcaseController` เพียงครั้งเดียวต่อหน้า (ไม่ควรสร้างใหม่ทุก `build`)
- ต้องเรียก `_controller.dispose()` ใน `State.dispose()` เสมอ
- `CustomShowcase` ต้องอยู่ใน Widget Tree ก่อนเรียก `start()` เพื่อให้ `GlobalKey` สามารถหาตำแหน่งของ Widget ได้
- Balloon จะมีความกว้างคงที่ที่ 240px และปรับความสูงตามเนื้อหา (max 3 บรรทัดของ description)
