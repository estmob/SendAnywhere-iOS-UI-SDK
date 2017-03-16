#ifndef PAPRIKA_TRANSFER_H_
#define PAPRIKA_TRANSFER_H_

#include <stdbool.h>
#include <wchar.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32)
#ifdef PAPRIKA_EXPORT
    #define PAPRIKA_EXTERN __declspec(dllexport)
#else
    #define PAPRIKA_EXTERN __declspec(dllimport)
#endif
#else
#define PAPRIKA_EXTERN
#endif /* _WIN32 */

PAPRIKA_EXTERN void paprika_set_apikey(const char* key);

// auth function
typedef void* PaprikaAuthToken;

PAPRIKA_EXTERN PaprikaAuthToken paprika_auth_create();
PAPRIKA_EXTERN PaprikaAuthToken paprika_auth_create_with_deviceid(
                                    const char* id, const char* password);
PAPRIKA_EXTERN void paprika_auth_close(PaprikaAuthToken auth);

PAPRIKA_EXTERN const char* paprika_auth_get_device_id(PaprikaAuthToken auth);
PAPRIKA_EXTERN const char* paprika_auth_get_device_password(PaprikaAuthToken auth);
PAPRIKA_EXTERN const char* paprika_auth_get_token(PaprikaAuthToken auth);

// option function
typedef enum {
    PAPRIKA_OPTION_API_SERVER = 0,
    PAPRIKA_OPTION_RESERVED1,
    PAPRIKA_OPTION_RESERVED2,
    PAPRIKA_OPTION_PROFILE_NAME,
    PAPRIKA_OPTION_RESERVED4,
    PAPRIKA_OPTION_RESERVED5,
    PAPRIKA_OPTION_RESERVED6,
    PAPRIKA_OPTION_RESERVED7,
    PAPRIKA_OPTION_RESERVED8,

#if defined(_WIN32) || defined(__CYGWIN__)
    // set proxy server
    PAPRIKA_OPTION_USING_PROXY_SERVER,
    PAPRIKA_OPTION_PROXY_USERID,
    PAPRIKA_OPTION_PROXY_PASSWORD,
#endif
} PaprikaOptionKey;

typedef void* PaprikaOption;

PAPRIKA_EXTERN PaprikaOption paprika_option_create();
PAPRIKA_EXTERN void paprika_option_close(PaprikaOption option);

PAPRIKA_EXTERN void paprika_option_set_value(PaprikaOption option,
                        PaprikaOptionKey key, const void* value);

// localinfo
PAPRIKA_EXTERN void paprika_local_set_osinfo(
                const char* osVersion, const char* osLanguage);
PAPRIKA_EXTERN void paprika_local_set_appinfo(
                const char* appName, const char* appVersion);
PAPRIKA_EXTERN void paprika_local_set_location(
                double latitude, double longitude);
PAPRIKA_EXTERN void paprika_local_set_device(
                const char* modelNumber, const char* carrierName, const char* networkCountry);
PAPRIKA_EXTERN void paprika_local_set_network(
                const char* deviceIp, const char* bssid, const char* networkState);

// task function

typedef enum {
    PAPRIKA_STATE_UNKNOWN = 0,

    // all task
    PAPRIKA_STATE_FINISHED,
    PAPRIKA_STATE_ERROR,
    PAPRIKA_STATE_PREPARING,

    // trasnfer task
    PAPRIKA_STATE_TRANSFERRING,
} PaprikaState;

typedef enum {
    PAPRIKA_DETAILED_STATE_UNKNOWN = 0,

    // all task
    PAPRIKA_DETAILED_STATE_FINISHED_SUCCESS,
    PAPRIKA_DETAILED_STATE_FINISHED_CANCEL,
    PAPRIKA_DETAILED_STATE_FINISHED_ERROR,

    PAPRIKA_DETAILED_STATE_ERROR_WRONG_API_KEY,
    PAPRIKA_DETAILED_STATE_ERROR_SERVER_WRONG_PROTOCOL,
    PAPRIKA_DETAILED_STATE_ERROR_SERVER_NETWORK,
    PAPRIKA_DETAILED_STATE_ERROR_REQUIRED_LOGIN,
    PAPRIKA_DETAILED_STATE_ERROR_SERVER_AUTHENTICATION,

    PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_DEVICE_ID,
    PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_AUTH_TOKEN,

    // transfer task
    /* PAPRIKA_TASK_UPLOAD, PAPRIKA_TASK_UPLOAD_REQ, PAPRIKA_TASK_UPLOAD_RES,
       PAPRIKA_TASK_DOWNLOAD, PAPRIKA_TASK_DOWNLOAD_REQ, PAPRIKA_TASK_DOWNLOAD_RES */
    PAPRIKA_DETAILED_STATE_PREPARING_REQUEST_KEY,
    PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_KEY,
    PAPRIKA_DETAILED_STATE_PREPARING_REQUEST_MODE,
    PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_MODE,
    PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST,
    PAPRIKA_DETAILED_STATE_PREPARING_WAIT_NETWORK,

    PAPRIKA_DETAILED_STATE_TRANSFERRING_ACTIVE,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_PASSIVE,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_SERVER,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_START_NEW_FILE,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_END_FILE,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_RESUME,
    PAPRIKA_DETAILED_STATE_TRANSFERRING_PAUSE,

    PAPRIKA_DETAILED_STATE_ERROR_FILE_NETWORK,
    PAPRIKA_DETAILED_STATE_ERROR_FILE_WRONG_PROTOCOL,

    // PAPRIKA_TASK_UPLOAD
    PAPRIKA_DETAILED_STATE_ERROR_NO_REQUEST,
    PAPRIKA_DETAILED_STATE_ERROR_NO_EXIST_FILE,

    // PAPRIKA_TASK_DOWNLOAD
    PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DOWNLOAD_PATH,
    PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DISK_SPACE,

    // PAPRIKA_TASK_DOWNLOAD, PAPRIKA_TASK_DELETE_KEY, PAPRIKA_TASK_QUERY_KEY
    PAPRIKA_DETAILED_STATE_ERROR_NO_EXIST_KEY,

    //
    PAPRIKA_DETAILED_STATE_ERROR_RESERVED31,
    PAPRIKA_DETAILED_STATE_ERROR_RESERVED32,
    PAPRIKA_DETAILED_STATE_ERROR_RESERVED33,
    PAPRIKA_DETAILED_STATE_ERROR_RESERVED34,

    // PAPRIKA_TASK_UPDATE_DEVICE
    PAPRIKA_DETAILED_STATE_ERROR_NEED_UPDATE,

    //
    PAPRIKA_DETAILED_STATE_RESERVED36,

    //
    PAPRIKA_DETAILED_STATE_RESERVED37,

    //
    PAPRIKA_DETAILED_STATE_RESERVED38,
    PAPRIKA_DETAILED_STATE_RESERVED39,
    PAPRIKA_DETAILED_STATE_RESERVED40,
    PAPRIKA_DETAILED_STATE_RESERVED41,
    PAPRIKA_DETAILED_STATE_RESERVED42,

    // all task
    PAPRIKA_DETAILED_STATE_ERROR_PROXY_AUTHENTICATION,

} PaprikaDetailedState;

typedef enum {
    /* PAPRIKA_TASK_UPLOAD, PAPRIKA_TASK_UPLOAD_REQ, PAPRIKA_TASK_UPLOAD_RES,
       PAPRIKA_TASK_DOWNLOAD, PAPRIKA_TASK_DOWNLOAD_REQ, PAPRIKA_TASK_DOWNLOAD_RES */
    PAPRIKA_VALUE_TRANSFER_KEY = 0,
    PAPRIKA_VALUE_TRANSFER_FILE_STATE,
    PAPRIKA_VALUE_TRANSFER_PEER_DEVICE_ID,

    // PAPRIKA_TASK_UPLOAD, PAPRIKA_TASK_UPLOAD_REQ, PAPRIKA_TASK_UPLOAD_RES,
    PAPRIKA_VALUE_UPLOAD_LINK_URL,
    PAPRIKA_VALUE_UPLOAD_EXPIRES_TIME,

    // PAPRIKA_TASK_QUERY_KEY
    PAPRIKA_VALUE_KEY_INFO,
} PaprikaValue;

typedef void* PaprikaTask;

typedef void (*paprika_listener_function)(
                    PaprikaState state,
                    PaprikaDetailedState detailedState,
                    const void* param,
                    void* userptr);

typedef struct {
    const wchar_t* name;
    const wchar_t* fullPath;
    unsigned long long size;
    unsigned long long sent;
} PaprikaTransferFileState;

typedef struct {
    unsigned int number;
    PaprikaTransferFileState* fileState;
} PaprikaAllTransferFileState;

typedef size_t (*paprika_upload_read_function)(
                char* buf, unsigned long long start, size_t n,
                void* userptr);
typedef struct {
    const wchar_t* name;
    const wchar_t* path;
    unsigned long long size;
    int time;
    paprika_upload_read_function readFunc;
    void* userData;
} PaprikaUploadFileInfo;

typedef enum {
    PAPRIKA_TRANSFER_DIRECT = 0,
    PAPRIKA_TRANSFER_UPLOAD,
    PAPRIKA_TRANSFER_HYBRID,
} PaprikaTransferMode;


// send/recv function
PAPRIKA_EXTERN PaprikaTask paprika_create_update_device();
PAPRIKA_EXTERN PaprikaTask paprika_create_upload(
        const wchar_t* files[], unsigned int fileNumber,
        PaprikaTransferMode trasnferMode);
PAPRIKA_EXTERN PaprikaTask paprika_create_upload_by_key(
        const wchar_t* files[], unsigned int fileNumber, const wchar_t* key,
        PaprikaTransferMode trasnferMode);
PAPRIKA_EXTERN PaprikaTask paprika_create_upload_stream(
        const wchar_t* files[], unsigned int fileNumber,
        const PaprikaUploadFileInfo streams[], unsigned int streamNumber,
        PaprikaTransferMode trasnferMode);

PAPRIKA_EXTERN PaprikaTask paprika_create_download(
        const wchar_t* key, const wchar_t* destDirPath);

PAPRIKA_EXTERN PaprikaTask paprika_create_delete_key(const wchar_t* key);


// general function for task
PAPRIKA_EXTERN void paprika_close(PaprikaTask task);

PAPRIKA_EXTERN void paprika_start(PaprikaTask task);
PAPRIKA_EXTERN void paprika_wait(PaprikaTask task);
PAPRIKA_EXTERN void paprika_cancel(PaprikaTask task);
PAPRIKA_EXTERN bool paprika_is_running(PaprikaTask task);

PAPRIKA_EXTERN void paprika_set_auth(PaprikaTask task, PaprikaAuthToken auth);
PAPRIKA_EXTERN void paprika_set_option(PaprikaTask task, PaprikaOption option);
PAPRIKA_EXTERN void paprika_set_listner(PaprikaTask task,
                        paprika_listener_function func, void* userptr);

PAPRIKA_EXTERN bool paprika_get_value(PaprikaTask task,
                        PaprikaValue value, void* param);

PAPRIKA_EXTERN const char* paprika_state_to_string(PaprikaState state);
PAPRIKA_EXTERN const char* paprika_detailedstate_to_string(PaprikaDetailedState state);

#ifdef __cplusplus
}
#endif

#endif // PAPRIKA_TRANSFER_H_

