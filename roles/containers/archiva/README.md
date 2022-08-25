# Apache Archiva

A Java Build Artifact Repository Manager.

## Settings

- **Disable password expiration** (you will lock out after expiration days!): Login as Admin : User Runtime Configuration : Properties : security.policy.password.expiration.enabled (Page 3) : set to `false`

- **Disable Registration:** UI Configuration : Disable registration link

## Maven Project

1. Create a user in Archiva to use for deployment
2. The deployment user needs the Role "Repository Manager" for each repository that you want to deploy to. (Archiva Settings : Manage : ${USER} : Edit : Edit Roles : Global Repository Manager : Save)
3. Create a `.mvn` folder inside the maven project root folder
4. Add a file `maven.config` with the following content to the this folder: `--settings ./.mvn/local-settings.xml`
5. Create `.mvn/local-settings.xml` and adjust the authentication information.

```
<settings>
    <servers>
        <server>
            <id>internal</id>
            <!-- TODO: Add your archiva authentication information -->
            <username>archiva</username>
            <password>Geheim</password>
            <!-- TODO: END -->
        </server>
        <server>
            <id>snapshots</id>
            <!-- TODO: Add your archiva authentication information -->
            <username>archiva</username>
            <password>Geheim</password>
            <!-- TODO: END -->
        </server>
    </servers>

    <profiles>
        <profile>
            <id>archiva</id>
            <properties>
                <!-- TODO: Add your repo urls (with default config change only the server ip)-->
                <snapshot.repo.url>http://10.0.0.123:8080/repository/snapshots/</snapshot.repo.url>
                <internal.repo.url>http://10.0.0.123:8080/repository/internal/</internal.repo.url>
                <!-- TODO: END -->
                <altSnapshotDeploymentRepository>snapshots::default::${snapshot.repo.url}</altSnapshotDeploymentRepository>
                <altReleaseDeploymentRepository>internal::default::${internal.repo.url}</altReleaseDeploymentRepository>
            </properties>
            <repositories>
                <repository>
                    <id>snapshots</id>
                    <name>Archiva Internal Snapshot Repository</name>
                    <url>${snapshot.repo.url}</url>
                    <snapshots><enabled>true</enabled></snapshots>
                </repository>
                <repository>
                    <id>internal</id>
                    <name>Archiva Internal Release Repository</name>
                    <url>${internal.repo.url}</url>
                    <releases><enabled>true</enabled></releases>
                    <snapshots><enabled>false</enabled></snapshots>
                </repository>
            </repositories>
        </profile>
    </profiles>

    <activeProfiles>
        <activeProfile>archiva</activeProfile>
    </activeProfiles>
</settings>
```

This method required maven-deploy-plugin version 2.8 or newer in your project `pom.xml`:

```
<build>
   <pluginManagement>
      <plugins>
         <plugin>
            <artifactId>maven-deploy-plugin</artifactId>
            <version>2.8</version>
         </plugin>
      ...
      </plugins>
   </pluginManagement>
</build>
```

The final Structure of the maven project root folder:

```
parent-mvn-project
   ├── .mvn
   │   ├── local-settings.xml
   │   └── maven.config
   ├── maven submodule-A
   ├── maven submodule-B
   ├── pom.xml
   └── ...
```

For better management i recommend to include the `.mvn` folder as a git submodule to your projects.
