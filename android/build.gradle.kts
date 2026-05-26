buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fixed: Use projectDirectory.dir() to correctly set the build directory as a Directory type
rootProject.layout.buildDirectory.set(layout.projectDirectory.dir("../build/${rootProject.name}"))

subprojects {
    // Fixed: Ensure subprojects also use the correct Directory type
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(project.name))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
