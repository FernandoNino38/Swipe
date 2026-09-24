allprojects {
    repositories {
        google()
        mavenCentral()
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
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val m = androidExt.javaClass.methods.firstOrNull { 
                        it.name == "compileSdkVersion" && it.parameterTypes.size == 1 
                    }
                    if (m != null) {
                        if (m.parameterTypes[0] == Int::class.javaPrimitiveType) {
                            m.invoke(androidExt, 36)
                        } else if (m.parameterTypes[0] == String::class.java) {
                            m.invoke(androidExt, "android-36")
                        }
                    }
                } catch (ignored: Exception) {}
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
