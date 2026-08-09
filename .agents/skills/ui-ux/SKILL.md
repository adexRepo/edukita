---
name: ui-ux
description: Design, implement, or review Edukita screens, layouts, desktop interactions, dialogs, tables, responsive behavior, and loading, empty, error, disabled, or success states. Use for UI consistency, usability, accessibility, overflow, keyboard, focus, and visual hierarchy work.
---

# UI and UX

1. Inspect the live screen, its data density, common workflow, and comparable maintained Edukita pages.
2. Reuse `AppTheme`, `AppColors`, Poppins typography, shared page/table/dialog/input/loading/toast components, and existing Material/Shadcn patterns.
3. Keep the operations UI quiet, compact, and scannable. Use cards only for genuine grouped tools or repeated items.
4. Establish hierarchy through spacing, typography, alignment, and clear primary actions rather than decoration.
5. Design relevant loading, empty, error, disabled, success, and read-only states.
6. Use constraints and flexible layout; verify 800x600 and maximized Windows sizes. Provide deliberate vertical/horizontal scrolling and attached controllers.
7. Preserve keyboard navigation, focus order, text scaling, contrast, tooltips/semantics for icon actions, and adequate hit targets.
8. Prevent content overlap and overflow. Do not solve it by clipping required content.
9. Keep destructive actions red, deliberate, confirmed, and protected against rapid duplicate dialogs.
10. Test interaction behavior as well as appearance.

Do not introduce gradients, decorative blobs, excessive shadows, arbitrary rounded cards, or a parallel design system.
