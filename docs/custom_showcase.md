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

> ระบบจะ Auto-detect พื้นที่ว่างบนหน้าจอ หากพื้นที่ตาม `placement` ไม่เพียงพอ (< 160px) จะ Fallback ไปยังทิศทางตรงข้ามโดยอัตโนมัติ

---

## ShowcaseStep

Data class สำหรับกำหนดข้อมูลของแต่ละ Tutorial Step

```dart
ShowcaseStep({
  required String title,
  required Widget content,
  Widget? headerWidget,
  ShowcasePlacement placement = ShowcasePlacement.below,
  double tailSize = 16.0,
})
```

### Parameters

| Parameter | Type | Default | คำอธิบาย |
|---|---|---|---|
| `title` | `String` | required | หัวข้อที่แสดงใน Balloon (ใช้ภายใน controller เท่านั้น) |
| `content` | `Widget` | required | Widget ที่แสดงในพื้นที่ body ของ Balloon — ใส่ได้ทุกประเภท |
| `headerWidget` | `Widget?` | `null` | Widget แสดงแบบ edge-to-edge ที่ขอบบนของ Balloon ดู [headerWidget](#headerwidget) |
| `placement` | `ShowcasePlacement` | `below` | ตำแหน่ง Balloon ที่ต้องการ |
| `tailSize` | `double` | `16.0` | ขนาด (ฐาน) ของหางสามเหลี่ยม เป็น px ปรับได้ต่อ Step |

### ตัวอย่าง content

`content` รับ Widget ใดก็ได้ ตัวอย่างรูปแบบที่ใช้ได้:

```dart
// Text ธรรมดา
content: const Text('คำอธิบาย...', style: TextStyle(fontSize: 12, color: Colors.black54))

// Row — icon + text
content: Row(
  children: [
    const Icon(Icons.flash_on_rounded, size: 16, color: Colors.amber),
    const SizedBox(width: 6),
    const Expanded(child: Text('คำอธิบาย...')),
  ],
)

// Column — หลายบรรทัด
content: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('บรรทัด 1'),
    Text('บรรทัด 2'),
  ],
)

// Wrap — tag chips
content: Wrap(
  spacing: 6,
  children: [Chip(label: Text('Tag 1')), Chip(label: Text('Tag 2'))],
)
```

### ตัวอย่างการปรับ tailSize

```dart
ShowcaseStep(title: '...', content: Text('...'), tailSize: 10)  // เล็ก
ShowcaseStep(title: '...', content: Text('...'))                 // default (16)
ShowcaseStep(title: '...', content: Text('...'), tailSize: 28)  // ใหญ่
```

---

## headerWidget

`Widget?` ที่แสดงแบบ **edge-to-edge** ที่ขอบบนสุดของ Balloon โดยถูก Clip ด้วยมุมโค้งของ Balloon (topLeft + topRight) เหมาะสำหรับ Lottie animation หรือ Image ที่ต้องการให้เต็มความกว้าง

### พฤติกรรม

- แสดงก่อน `content` เสมอ ไม่มี horizontal padding
- ถูก Clip ด้วย `ClipRRect` ที่มุมบนซ้ายและบนขวา ให้ตรงกับขอบ Balloon
- **ปุ่ม X (Close)** วางซ้อนทับมุมบนขวาของ header โดยอัตโนมัติ (ไม่ต้องกำหนดเอง)
- สำหรับ `below` placement: header จะถูกดันลงมาให้เริ่มตรงกับขอบบนของ body (หลัง tail area)

### ตัวอย่างการใช้ Lottie เป็น header

```dart
ShowcaseStep(
  title: 'Menu 1',
  placement: ShowcasePlacement.below,
  headerWidget: Lottie.asset(
    'assets/lottie/step_01.json',
    height: 160,
    width: double.infinity,
    fit: BoxFit.cover,
  ),
  content: const Text(
    'คำอธิบาย Menu 1',
    style: TextStyle(fontSize: 12, color: Colors.black54),
  ),
)
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
      // Step ธรรมดา — content เป็น Text
      ShowcaseStep(
        title: 'ปุ่มค้นหา',
        placement: ShowcasePlacement.below,
        content: const Text(
          'แตะที่นี่เพื่อค้นหาสิ่งที่ต้องการ',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
      // Step มี Lottie header
      ShowcaseStep(
        title: 'ปุ่มเพิ่ม',
        placement: ShowcasePlacement.leftOf,
        tailSize: 20,
        headerWidget: Lottie.asset('assets/lottie/add.json', height: 120),
        content: const Text('สร้างรายการใหม่ได้ที่นี่'),
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
      CustomShowcase(
        controller: _controller,
        stepIndex: 0,
        child: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
      ),
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
- **แตะ Backdrop:** ไม่มีผลใดๆ — ต้องปิดผ่านปุ่ม X หรือ Done เท่านั้น
- **ปุ่ม X:** วางซ้อนทับมุมบนขวาของ `headerWidget` (circle button กึ่งโปร่งใส) — ปิด Tutorial ทั้งหมด
- **ปุ่ม Next:** เลื่อนไปยัง Step ถัดไป อยู่ใน footer ของ Balloon
- **ปุ่ม Done:** แสดงแทน Next เมื่อถึง Step สุดท้าย กดแล้วปิด Tutorial
- **Step Counter:** แสดง `ปัจจุบัน / ทั้งหมด` มุมล่างซ้ายของ Balloon
- **Balloon Width:** เต็มความกว้างจอ หักขอบซ้าย-ขวา 16px ต่อข้าง

---

## Balloon Layout

### ไม่มี headerWidget

```
┌──────────────────────────────┐  ← rounded corners
│  content widget              │
│  ─────────────────────────── │
│  1 / 3              [ Next ] │
└──────────────────────────────┘
              ▲  tail
```

### มี headerWidget (placement: below)

```
              ▲  tail
┌──────────────────────────────┐  ← rounded corners + ClipRRect
│  [Lottie / Image]        [X] │  ← headerWidget (edge-to-edge) + close button
├──────────────────────────────┤
│  content widget              │
│  ─────────────────────────── │
│  1 / 3              [ Next ] │
└──────────────────────────────┘
```

---

## การเพิ่ม Tutorial ใหม่

1. เพิ่ม `ShowcaseStep` เข้าไปในรายการ `steps` ของ Controller
2. ห่อ Widget เป้าหมายด้วย `CustomShowcase` พร้อมระบุ `stepIndex` ที่ถูกต้อง

```dart
// เพิ่ม Step ใหม่
ShowcaseStep(
  title: 'ฟีเจอร์ใหม่',
  placement: ShowcasePlacement.above,
  content: const Text('คำอธิบายฟีเจอร์ใหม่ที่เพิ่มเข้ามา'),
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
- Balloon กว้างเต็มจอ (หักขอบ 16px ต่อข้าง) และความสูงปรับตาม `content` + `headerWidget`
- `headerWidget` ที่ใช้ Lottie ควรกำหนด `height` ตายตัวและ `fit: BoxFit.cover` เพื่อให้ fill พื้นที่และถูก clip ที่ขอบ Balloon ได้อย่างถูกต้อง
