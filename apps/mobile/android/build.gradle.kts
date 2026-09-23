allprojects {
    repositories {
        google()
        mavenCentral()
    }

    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.pusher" &&
                requested.name == "pusher-java-client"
            ) {
                useVersion("2.4.4")
            }
            if (requested.group == "com.google.code.gson" &&
                requested.name == "gson"
            ) {
                useVersion("2.14.0")
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

// sentry_flutter hardcodes Kotlin languageVersion 1.6, which Kotlin 2.2 rejects.
subprojects {
    val bump = {
        tasks
            .withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
            .configureEach {
                compilerOptions {
                    languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_8)
                    apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_8)
                }
            }
    }
    if (state.executed) bump() else afterEvaluate { bump() }
}
