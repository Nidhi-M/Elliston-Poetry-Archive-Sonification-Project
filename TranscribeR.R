##this is using HP Haven Speech to text feature; an account has to be created and API associated with the account is to be used.

library(transcribeR)
WAV_DIR <- 'Path to directory which has all the wav files'
API_KEY <- 'API key'


TranscribeAudio <- function (WAV_FILE) {
  TEMP_DIR <- file.path(WAV_DIR,"Temp" )
  if (dir.exists(TEMP_DIR) ==FALSE) {
    dir.create(TEMP_DIR )
  }
  TEMPWAV_FILE <- paste(TEMP_DIR, WAV_FILE, sep = '/')
  WAV_FILEPATH <- paste(WAV_DIR, WAV_FILE, sep = "/")
  file.copy(WAV_FILEPATH, TEMPWAV_FILE)
  CSV_LOCATION <- paste(WAV_DIR,"/transcribe.csv", sep = "")
  sendAudioGetJobs(wav.dir = TEMP_DIR,
                   api.key = API_KEY,
                   interval = "-1",             # Transcript will not be segmented
                   encode = "multipart",
                   existing.csv = NULL,         # Intended to create a new CSV
                   csv.location = CSV_LOCATION,
                   language = "en-US",          # As printed above, one of the language codes
                   verbose = TRUE) 
  
  Sys.sleep(360) ## wait for transcription
  TEXT <- retrieveText(job.file = CSV_LOCATION,
             api.key = API_KEY)
  if (TEXT[,'TRANSCRIPT'] == 'queued')
  { Sys.sleep(240)
    TEXT <- retrieveText(job.file = CSV_LOCATION,
                         api.key = API_KEY)
    }
  FILE_NAME <- paste(TEXT[, 'FILENAME'], ".txt", sep ="")
  TEXT_LOCATION <- file.path(WAV_DIR, FILE_NAME )
  file.create(TEXT_LOCATION)
  write.table(TEXT[,'TRANSCRIPT'],file=TEXT_LOCATION)
  print(TEXT[,'TRANSCRIPT'])
  file.remove(CSV_LOCATION)
  file.remove(TEMPWAV_FILE)
  return()
}

files <- as.list(list.files(path=WAV_DIR,full.names = FALSE, pattern='*.wav'))
lapply(files,FUN = TranscribeAudio)


