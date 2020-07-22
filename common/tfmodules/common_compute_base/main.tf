
locals {
  common_instance_scheduler_tags = {
      "Scheduler_Start"      = var.common_compute_scheduler.start_frequency
      "Scheduler_Start_Time" = var.common_compute_scheduler.start_time_utc
      "Scheduler_Stop"       = var.common_compute_scheduler.stop_frequency
      "Scheduler_Stop_Time"  = var.common_compute_scheduler.stop_time_utc
  }

  common_instance_windows_tags = {
      "OS_Family"         = var.common_compute_vm_windows.os_family
      "OS_Architecture"   = var.common_compute_vm_windows.os_arch
      "OS_Description"    = var.common_compute_vm_windows.os_description
  }
  
  common_instance_linux_tags = {
      "OS_Family"         = var.common_compute_vm_linux.os_family
      "OS_Architecture"   = var.common_compute_vm_linux.os_arch
      "OS_Description"    = var.common_compute_vm_linux.os_description
  }
}