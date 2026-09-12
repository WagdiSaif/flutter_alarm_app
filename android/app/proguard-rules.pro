
-keep class com.wagdi.alarmapp.MainActivity { *; }
-keep class com.wagdi.alarmapp.** { *; }


-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager


-keep class com.wagdi.alarmapp.R$drawable {
    public static final int ic_bg_service_notification;
}
