Driver usage
==========

Supported hardware configurations:
---------------------------------

* 4 core, 128 events, 24 counters -> Driver folder ```4-core```
* 6 core, 128 events, 24 counters -> Driver folder ```6-core```
* 6 core, 256 events, 24 counters (customization for SELENE platform) -> Driver folder ```6-core-256e```


RTL and C drivers are tightly integrated, but both have different levels of parametrization.
Due to these limitations, unsupported configurations may require manual changes on the RTL, drivers, or both.

Driver files
-----------
* pmu_vars.h: contains defines with the same names as the **safeSU/PMU RTL** parameters and local parameters.
* pmu_hw.h: Header for PMU functions and SoC address for safeSU and PLIC
* pmu_hw.c: Pmu functions

Notes on portability
-------------------
If you need to modify the drivers of RTL of the unit the file ```/selene-hardware/safety/ahb_pmu/bsc_pmu/docs/ahb_pmu_mem_map.ods```
can help you to precalculate some of the values for the RTL and drivers. Alternatively, spyglass summarizes the parameters as a result of linting (`elab_summary.rpt`). If CI is deployed, the summary will be available as an artifact, otherwise, you can run it
locally or on a remote machine by modifying ```selene-hardware/safety/ahb_pmu/bsc_pmu/ci/runLintSV.sh``` with your credentials.

Upcoming releases
-----------------
We are working towards a more seamless integration and software unit tests. Contributions are welcome.
