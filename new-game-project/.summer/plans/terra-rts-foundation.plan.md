---
name: terra-rts-foundation
overview: >-
  Build Terra as a cooperative 3D top-down RTS, starting with a small
  command-and-resource loop before expanding toward base building and hard
  objectives.
createdAt: '2026-08-14T22:36:07.624Z'
todos:
  - id: playable-battlefield
    content: >-
      Build the first playable 3D top-down battlefield with camera, terrain, one
      commandable unit, and one tactical order.
    status: in_progress
  - id: resource-loop
    content: >-
      Add visible resource nodes and a resource collection loop that rewards
      sending the unit to a node.
    status: pending
  - id: base-building
    content: >-
      Add a minimal base-building action with placement feedback and a first
      useful structure.
    status: pending
  - id: objective-enemy
    content: >-
      Add one hard objective with an opposing threat so the slice has a clear
      win or fail condition.
    status: pending
  - id: cooperative-ready
    content: >-
      Shape the command and objective boundaries so a later co-op player can
      share the battlefield without replacing the single-player loop.
    status: pending
  - id: content-pass
    content: >-
      Tune readability, feedback, and presentation around the Terra vision after
      the core slice is playable.
    status: pending
---
Direction: Terra is a 3D top-down cooperative RTS. Players fight hard objectives and environmental or AI threats rather than other players. The first playable slice should be one scene with a readable battlefield, camera pan/zoom, a commandable unit, resource nodes, and a tactical order. The single spine example is freeform because the examples catalog has no close RTS slice; use the scene-first order instead of stitching unrelated recipes together.

First milestone: prove the command loop before menus, networking, broad content, or polish. The user should be able to press Play, see the battlefield, select the unit, issue a move order, and receive clear movement feedback. Then layer resource collection, construction, and one objective around that working base.

Working decisions: 3D, top-down, cooperative PvE rather than competitive PvP. Keep world forward conventions consistent if a controller or procedural placement system is introduced. Preserve a single main scene for the first slice and avoid infrastructure that is not needed to feel the loop.

Verification: after each meaningful milestone, use the editor diagnostics for script errors. Ask the user to press Play and report how selection, movement, resource collection, and placement feel before expanding the slice. Do not treat compilation or a still frame as proof of gameplay.
