

source_dir <- paste0(root.data.directory, "import/")
filenames  <- list.files(source_dir)
filepaths  <-  

  filepaths <- paste0(source_dir, filenames) %>%
                base::file.info() %>%
                dplyr::arrange(size) %>%
                {row.names(.)}


#session <- ssh::ssh_connect("ubuntu@graph.constellationsproject.app", keyfile = paste0(root.security.directory, "neo4j-aws-newkey.pem"))
session <- ssh::ssh_connect("ubuntu@54.227.155.144", keyfile = paste0(root.security.directory, "neo4j-aws-newkey.pem"))


for (i in seq_along(filepaths)){
  ssh::scp_upload(session, files = filepaths[i], to = "import/")
}

ssh::ssh_exec_wait(session, command = c(
  'sudo rm -r /var/lib/neo4j/import',
  'sudo cp -r ~/import /var/lib/neo4j/',
  'cd ~/import',
  'sudo rm -r *'
))


ssh::ssh_disconnect(session)