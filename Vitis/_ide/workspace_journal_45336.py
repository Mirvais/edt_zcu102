# 2026-02-27T19:54:13.076481300
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis")

platform = client.get_component(name="zcu102_edt")
status = platform.build()

