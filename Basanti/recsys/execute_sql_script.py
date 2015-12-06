import logging

def execute_from_file(filename, cursor):
    fd = open(filename, 'r')
    sqlFile = fd.read()
    fd.close()

    sqlCommands = sqlFile.split(';')

    for command in sqlCommands:
        try:
            cursor.execute(command)
        except:
            logger = logging.getLogger("Rotating Log")
            logger.warn("error executing command:")
            logger.warn(command)
