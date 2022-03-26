import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.findOrSetObject
import com.github.ajalt.clikt.core.requireObject
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.options.required

class PostgresSchema: CliktCommand(printHelpOnEmptyArgs = true) {
    private val connectionString: String by option("-c", "--connection-string",
        help = "The psql connection string used to connect to the database").required()
    private val config by findOrSetObject { mutableMapOf<String, String>() }
    override fun run() {
        config["CONNECTION_STRING"] = connectionString
    }
}

class Snapshot: CliktCommand(help="Take a snapshot of a schema") {
    private val config by requireObject<Map<String, String>>()
    override fun run() {
        echo("Snapshotting ...")
        // pg_dump "host=172.17.0.5 port=5432 dbname=postgres user=postgres" --schema=${SOURCE_SCHEMA} --format=custom --blobs --file=/leanix/snapshot/roman-snap.dump
        echo(executeCommandAndCaptureOutput(listOf("echo", "${config["CONNECTION_STRING"]}")))
    }
}



class Restore: CliktCommand(help="Restore a snapshot to a schema") {
    override fun run() {
        echo("Restoring ...")
    }
}

fun main(args: Array<String>) = PostgresSchema()
    .subcommands(Snapshot(), Restore())
    .main(args)