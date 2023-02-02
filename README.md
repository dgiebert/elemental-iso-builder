# elemental-iso-builder

## Usage

1. Put rpm packages to be installed into the folder for your architecture e.g. `packages/linux/amd64`
2. Create a custom script to adapt the ISO check `scripts/linux/arm64/rpi.sh`
3. Run the command to build your images
```
> sudo ./build.sh -r "dgiebert/elemental" -t "v0.0.6 -p linux/arm64,linux/amd64"
```
4. Check the `output` folder and flash or use the built ISO

