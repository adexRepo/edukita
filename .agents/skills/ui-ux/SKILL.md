---
name: ui-ux
description: Use when designing, reviewing, auditing, or improving Edukita Flutter screens and user flows. Apply the established Edukita Desktop Operations Style: a Windows-first Material 3 foundation with Shadcn controls and restrained macOS-like polish, not a pure iOS or Cupertino interface. Covers usability, interaction efficiency, visual hierarchy, accessibility, responsive desktop behavior, dialogs, tables, keyboard and focus handling, overflow, and loading, empty, error, disabled, success, or read-only states. Also use when an existing flow may be confusing, inefficient, inconsistent, or unnecessarily complex.
---

# UI and UX

## Visual identity

Treat Edukita as a compact desktop operations application, not a mobile app enlarged for desktop.

- Use Material 3 for application structure, behavior, state, focus, navigation, and accessibility.
- Use established Shadcn components for forms and selected controls where the feature already uses them. Do not mix Material and Shadcn arbitrarily within one form.
- Use restrained macOS-like qualities only as polish: clean white surfaces, soft gray backgrounds, thin borders, subtle shadows, calm spacing, and clear hierarchy.
- Do not imitate iOS/Cupertino navigation, large mobile titles, floating mobile sheets, touch-first spacing, or platform-specific controls without a real platform requirement.
- Use Poppins and centralized `AppTypography`. Keep page titles compact, section headings modest, body text dense but readable, and table text optimized for scanning.
- Use the existing white, soft-gray, charcoal, and turquoise palette. Reserve blue, purple, green, amber, and red for meaningful data or status distinctions.
- Prefer thin borders and low or zero elevation. Use approximately 8px radius for cards and grouped surfaces, and the existing 10-12px radius for dialogs, buttons, and inputs. Use pill shapes only for statuses, compact filters, or segmented controls.
- Use familiar Material icons. Icon-only actions require a tooltip and a clear hover/focus state.
- Keep hover subtle and stable: light surface or primary tint, no sudden color flash, movement, or shadow jump.
- Keep tables as the primary pattern for operational data. Preserve headers and empty structure, align numeric/action columns predictably, and use separators that support scanning without making every cell visually heavy.

## Workflow

1. Inspect the live screen, its data density, primary workflow, user role, and comparable maintained Edukita pages.
2. Reuse `AppTheme`, `AppColors`, `AppTypography`, Poppins, shared page/table/dialog/input/loading/toast components, and the feature's established Material or Shadcn pattern.
3. Reduce steps and pointer travel for repeated desktop tasks. Keep primary actions discoverable and secondary actions compact.
4. Establish hierarchy through spacing, typography, alignment, grouping, and clear actions rather than decoration.
5. Keep page sections unframed where possible. Use cards only for repeated records, summary metrics, dialogs, or genuinely bounded tools; never nest decorative cards.
6. Design relevant loading, empty, error, disabled, success, and read-only states. Preserve stable layout during refresh to avoid blinking or shifting.
7. Use constraints and flexible layout; verify 800x600, intermediate window sizes, and maximized Windows layouts. Provide deliberate scrolling with correctly attached controllers.
8. Preserve keyboard navigation, logical focus order, Enter/Escape behavior, text scaling, contrast, tooltips/semantics, and adequate desktop hit targets.
9. Prevent overlap and overflow through responsive composition. Do not hide required content with clipping or unexplained truncation.
10. Keep destructive actions red, deliberate, confirmed, and protected against rapid duplicate dialogs or submissions.
11. Test interaction behavior, focus, hover, loading transitions, empty data, minimized-window layout, and appearance.

Do not introduce gradients, decorative blobs, glass effects, excessive shadows, oversized typography, arbitrary rounded cards, generic mobile layouts, or a parallel design system.
