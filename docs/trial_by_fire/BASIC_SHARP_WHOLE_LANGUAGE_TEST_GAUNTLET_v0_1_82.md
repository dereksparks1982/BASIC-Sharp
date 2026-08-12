# BASIC# v0.1.82 Whole-Language Test Gauntlet

v0.1.82 preserves the locked full-count Trial by Fire defaults:

```text
events per path: 128000
platform frames: 128000
combined input/movement frames: 64000
ASK questions: 32000
save checkpoints: 1250
isolated worlds: 320
generated programs: 384
mutations per boundary: 3072
follow-up boundaries: 1023 / 1024 / 1025
```

The native parser dispatch and native semantic routing integration gates must pass before the final gauntlet. Profiles 1-7 and all 14 protected artifacts remain locked.

## Build-side exact-count evidence

All locked counts were exercised. The build host command ceiling required the four 128,000-event execution paths to run separately; source, saved BSIR, BSharp VM, and repeated BSharp VM all produced `8025f1af649580fe2d2ada51729966c93acb105c57932f22a1bcfab53817c4ef`. Every remaining phase ran at the exact counts above. The reconstructed semantic results SHA-256 is `ed8846886d9f47998c9f98a1da1863b51569b51b50c4e63cb261946925a24a8d`. Native acceptance still requires the installer to run the canonical unsharded gauntlet.
