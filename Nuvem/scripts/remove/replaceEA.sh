#!/bin/bash

cp DADGER.RV0 DADGER_BKP.RV0;

IDX=$(awk '/^EA/{ print NR-1; exit }' DADGER.RV0);
sed -i '/^EA/d' DADGER.RV0;
sed -i "${IDX} r EA.DAT" DADGER.RV0;

exit 0;








