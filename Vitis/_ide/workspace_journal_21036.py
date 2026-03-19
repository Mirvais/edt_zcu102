# 2026-02-26T03:37:05.768250100
import vitis

client = vitis.create_client()
client.set_workspace(path="Vitis")

advanced_options = client.create_advanced_options_dict(dt_overlay="0")

platform = client.create_platform_component(name = "zcu102_edt",hw_design = "$COMPONENT_LOCATION/../../edt_zcu102_wrapper.xsa",os = "standalone",cpu = "psu_cortexa53_0",domain_name = "standalone_psu_cortexa53_0",generate_dtb = False,advanced_options = advanced_options,architecture = "64-bit",compiler = "gcc")

platform = client.get_component(name="zcu102_edt")
status = platform.build()

comp = client.create_app_component(name="hello_a53",platform = "$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm",domain = "standalone_psu_cortexa53_0",template = "hello_world")

proj = client.create_sys_project(name="hello_a53_system", platform="$COMPONENT_LOCATION/../zcu102_edt/export/zcu102_edt/zcu102_edt.xpfm", template="empty_accelerated_application" , build_output_type="xsa")

proj = client.get_sys_project(name="hello_a53_system")

proj = proj.add_component(name="hello_a53")

status = platform.build()

comp = client.get_component(name="hello_a53")
comp.build()

vitis.dispose()

