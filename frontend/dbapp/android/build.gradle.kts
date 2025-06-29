allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    configurations.all {
        resolutionStrategy {
            force("org.bouncycastle:bcprov-jdk18on:1.76")
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
buildscript {
    repositories {
        google()  // ✅ Add this to fix the missing repository issue
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.6.0")  // ✅ Check for the latest Gradle version
        classpath("com.google.gms:google-services:4.3.10")  // ✅ Ensure this is present
    }
}

allprojects {
    repositories {
        google()  // ✅ This must be included
        mavenCentral()
    }
}


