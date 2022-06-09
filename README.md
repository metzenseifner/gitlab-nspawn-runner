# Gitlab Nspawn Runner

This repository contains the important files I used when creating a Gitlab
Runner that uses systemd-nspawn to isolate build environments. 


Inspiration for this comes from Josef Kufner and Enrico Zini. Josef Kufner uses an SSH Executor to
to trigger socket activation of new containers. Enrico Zini uses a Custom Executor with all of the lifecycle
routines defined as Bash scripts. This approach aligns more with the one used in this repository.
