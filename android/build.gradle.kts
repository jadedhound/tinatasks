allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    extra["kotlin_version"] = "1.9.0"
}

rootProject.buildDir = File("../build")

subprojects {
    buildDir = File("${rootProject.buildDir}/${name}")
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
