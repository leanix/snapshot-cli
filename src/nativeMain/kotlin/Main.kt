import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.subcommands

class PostgresSchema: CliktCommand() {
    override fun run() = Unit
}

class Snapshot: CliktCommand(help="Take a snapshot of a schema") {
    override fun run() {
        echo("Snapshotting ...")
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