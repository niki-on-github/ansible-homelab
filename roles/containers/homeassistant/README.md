# Home Assistant

Home Assistant is a free and open-source software for home automation that is designed to be the central control system for smart home devices with focus on local control and privacy.

### Home Assistant Installation Methods

| Name       | Required Skills | Includes Supervisor |  Supports Add-ons  | Supports Snapshots | Includes Operating System |    Uses Docker     | Method       |
| ---------- | :-------------: | :-----------------: | :----------------: | :----------------: | :-----------------------: | :----------------: | :----------- |
| OS         |     Novice      | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |    :heavy_check_mark:     | :heavy_check_mark: | Disk image   |
| Supervised |  Linux, Docker  | :heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |            :x:            | :heavy_check_mark: | Shell script |
| Container  |     Docker      |         :x:         |        :x:         |        :x:         |            :x:            | :heavy_check_mark: | Docker       |
| Core       |      Linux      |         :x:         |        :x:         |        :x:         |            :x:            |        :x:         | Python app   |

### Container Installation

The container Installation of Home Assistant has no Supervisor tab in the web UI and does not support Add-Ons!

## ConBee II in Home Assistant

### Methode 1 (recommend)

Use zigbee2mqtt and pass the zigbee2mqtt docker container (by adjusting the docker-compose file)

### Methode 2

Use `Zigbee home automation` Integration in Home Assistant. Therefore you have to pass the device to the Home Assistant docker container (by adjusting the docker-compose file)

### Method 3

You can use ConBeeII with deCONZ docker container and integrate with deCONZ Integration plugin in Home Assistant. Therefore you have to pass the device to the deCONZ docker container (by adjusting the docker-compose file)
