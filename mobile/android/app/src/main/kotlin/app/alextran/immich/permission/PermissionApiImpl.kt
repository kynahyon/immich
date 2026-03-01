package app.alextran.immich.permission

import android.content.Context
import android.os.PowerManager

class PermissionApiImpl(context: Context) : PermissionApi {
  private val ctx: Context = context.applicationContext

  private val powerManager =
    ctx.getSystemService(Context.POWER_SERVICE) as PowerManager


  override fun isIgnoringBatteryOptimizations(): PermissionStatus {
    if (powerManager.isIgnoringBatteryOptimizations(ctx.packageName)) {
      return PermissionStatus.GRANTED
    }
    return PermissionStatus.DENIED
  }
}
