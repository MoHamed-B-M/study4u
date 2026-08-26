allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ---------------------------------------------------------------------------
// Consistent JVM targets: some older plugins (e.g. flutter_vibrate) pin Java
// to 1.8 while newer Kotlin GradlePlugin defaults compile tasks to 17, which
// fails the build with "Inconsistent JVM Target Compatibility". Force every
// Android subproject onto the same target as :app (17).
// ---------------------------------------------------------------------------
subprojects {
    afterEvaluate {
        (extensions.findByName("android")
            as? com.android.build.gradle.BaseExtension)?.apply {
            // Older Flutter plugins pin low compileSdk versions; their merged
            // resources then fail to link modern framework attrs such as
            // android:attr/lStar. Align every subproject with :app.
            compileSdkVersion(36)
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java)
            .configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
