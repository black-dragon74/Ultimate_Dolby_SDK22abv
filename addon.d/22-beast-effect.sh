#!/sbin/sh

# Backup survival script by black.dragon74
# This script will backup your dolby Digital Plus and Atmos during updating/dirty flashing you ROM
# Let's start

#!/sbin/sh

. /tmp/backuptool.functions

list_files() {
cat <<EOF
addon.d/22-beast-effect.sh
app/GlobalDolbyEffect.apk
app/GlobalDolbyEffect/GlobalDolbyEffect.apk
app/GlobalDolbyEffect/lib/arm/libdolbyaudioeffectnativeservice.so
app/GlobalDolbyEffect/lib/arm/libdolbymobileaudioeffect_jni.so
lib/libdolbyaudioeffectnativeservice.so
lib/libdolbymobileaudioeffect_jni.so
lib/soundfx/libdolbymobileeffect.so
etc/dolby_config.xml
app/As.apk
app/AsUI.apk
app/As/As.apk
app/AsUI/AsUI.apk
lib/libdlbdapstorage.so
lib/soundfx/libswdap-mod.so
etc/dolby/ds-default.xml
bin/pullsvn
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
	# Stub
  ;;
  post-restore)
	DDP_CONFIG_FILE=/system/etc/audio_effects.conf
	DDP_VENDOR_CONFIG=/system/vendor/etc/audio_effects.conf
	DAP_CONFIG_FILE=/system/etc/audio_effects.conf
	DAP_VENDOR_CONFIG=/system/vendor/etc/audio_effects.conf

	if [ -f $DDP_VENDOR_CONFIG ];
	then
		CONFIG_FILE=$DDP_VENDOR_CONFIG
	fi
	
	sed -i '/dolby_mobile/,/}/d' $DDP_CONFIG_FILE
	sed -i 's/^libraries {/libraries {\n  dolby_mobile {\n    path \/system\/lib\/soundfx\/libdolbymobileeffect.so\n  }/g' $DDP_CONFIG_FILE
	sed -i 's/^effects {/effects {\n  dolby_mobile {\n    library dolby_mobile\n    uuid 7c0cb5a0-6705-11e0-ae3e-0002a5d5c51b\n  }/g' $DDP_CONFIG_FILE
	
	if [ -f $DAP_VENDOR_CONFIG ];
	then
		sed -i '/dap {/,/}/d' $DAP_VENDOR_CONFIG
		sed -i 's/^libraries {/libraries {\n  dap {\n    path \/system\/lib\/soundfx\/libswdap-mod.so\n  }/g' $DAP_VENDOR_CONFIG
		sed -i 's/^effects {/effects {\n  dap {\n    library dap\n    uuid 9d4921da-8225-4f29-aefa-39537a041337\n  }/g' $DAP_VENDOR_CONFIG
	fi
	
	sed -i '/dap {/,/}/d' $DAP_CONFIG_FILE
	sed -i 's/^libraries {/libraries {\n  dap {\n    path \/system\/lib\/soundfx\/libswdap-mod.so\n  }/g' $DAP_CONFIG_FILE
	sed -i 's/^effects {/effects {\n  dap {\n    library dap\n    uuid 9d4921da-8225-4f29-aefa-39537a041337\n  }/g' $DAP_CONFIG_FILE
  ;;
esac
