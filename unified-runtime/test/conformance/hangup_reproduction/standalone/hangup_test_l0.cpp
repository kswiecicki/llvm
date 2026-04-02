#include <gtest/gtest.h>
#include <level_zero/ze_api.h>
#include <vector>

class L0HangupReproTest : public ::testing::Test {
protected:
  void SetUp() override {
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeInit(0));

    uint32_t driverCount = 0;
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeDriverGet(&driverCount, nullptr));
    ASSERT_GT(driverCount, 0u);

    std::vector<ze_driver_handle_t> drivers(driverCount);
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeDriverGet(&driverCount, drivers.data()));
    driver = drivers[0];

    uint32_t deviceCount = 0;
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeDeviceGet(driver, &deviceCount, nullptr));
    ASSERT_GT(deviceCount, 0u);

    std::vector<ze_device_handle_t> devices(deviceCount);
    ASSERT_EQ(ZE_RESULT_SUCCESS,
              zeDeviceGet(driver, &deviceCount, devices.data()));
    device = devices[0];

    ze_device_properties_t devProps = {};
    devProps.stype = ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES;
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeDeviceGetProperties(device, &devProps));
    printf("Device: %s\n", devProps.name);

    ze_context_desc_t contextDesc = {};
    contextDesc.stype = ZE_STRUCTURE_TYPE_CONTEXT_DESC;
    ASSERT_EQ(ZE_RESULT_SUCCESS,
              zeContextCreate(driver, &contextDesc, &context));
  }

  void TearDown() override {
    if (context) {
      zeContextDestroy(context);
    }
  }

  ze_event_handle_t createEvent() {
    ze_event_handle_t event;

    ze_event_pool_counter_based_exp_desc_t counterBasedExt = {
        ZE_STRUCTURE_TYPE_COUNTER_BASED_EVENT_POOL_EXP_DESC, nullptr,
        ZE_EVENT_POOL_COUNTER_BASED_EXP_FLAG_IMMEDIATE};

    ze_event_pool_desc_t poolDesc = {};
    poolDesc.stype = ZE_STRUCTURE_TYPE_EVENT_POOL_DESC;
    poolDesc.pNext = &counterBasedExt;
    poolDesc.flags = ZE_EVENT_POOL_FLAG_HOST_VISIBLE;
    poolDesc.count = 1;
    EXPECT_EQ(ZE_RESULT_SUCCESS,
              zeEventPoolCreate(context, &poolDesc, 1, &device, &eventPool));

    ze_event_desc_t eventDesc = {};
    eventDesc.stype = ZE_STRUCTURE_TYPE_EVENT_DESC;
    eventDesc.index = 0;
    eventDesc.signal = ZE_EVENT_SCOPE_FLAG_HOST;
    eventDesc.wait = 0;
    EXPECT_EQ(ZE_RESULT_SUCCESS, zeEventCreate(eventPool, &eventDesc, &event));

    return event;
  }

  void destroyEvent(ze_event_handle_t event) {
    zeEventDestroy(event);
    if (eventPool) {
      zeEventPoolDestroy(eventPool);
      eventPool = nullptr;
    }
  }

  ze_driver_handle_t driver = nullptr;
  ze_device_handle_t device = nullptr;
  ze_context_handle_t context = nullptr;
  ze_event_pool_handle_t eventPool = nullptr;
};

#define L0_EVENTS_WAIT_TEST(N)                                                 \
  TEST_F(L0HangupReproTest, L0EventsWait##N) {                                 \
    ze_command_queue_desc_t queueDesc = {};                                    \
    queueDesc.stype = ZE_STRUCTURE_TYPE_COMMAND_QUEUE_DESC;                    \
    queueDesc.mode = ZE_COMMAND_QUEUE_MODE_ASYNCHRONOUS;                       \
    queueDesc.priority = ZE_COMMAND_QUEUE_PRIORITY_NORMAL;                     \
    queueDesc.flags = ZE_COMMAND_QUEUE_FLAG_IN_ORDER;                          \
                                                                               \
    ze_command_list_handle_t zeCommandList;                                    \
    ASSERT_EQ(ZE_RESULT_SUCCESS,                                               \
              zeCommandListCreateImmediate(context, device, &queueDesc,        \
                                           &zeCommandList));                   \
                                                                               \
    ze_event_handle_t zeEvent = createEvent();                                 \
                                                                               \
    ASSERT_EQ(ZE_RESULT_SUCCESS,                                               \
              zeCommandListAppendSignalEvent(zeCommandList, zeEvent));         \
                                                                               \
    ASSERT_EQ(ZE_RESULT_SUCCESS,                                               \
              zeCommandListHostSynchronize(zeCommandList, UINT64_MAX));        \
                                                                               \
    destroyEvent(zeEvent);                                                     \
    ASSERT_EQ(ZE_RESULT_SUCCESS, zeCommandListDestroy(zeCommandList));         \
  }

L0_EVENTS_WAIT_TEST(001)
L0_EVENTS_WAIT_TEST(002)
L0_EVENTS_WAIT_TEST(003)
L0_EVENTS_WAIT_TEST(004)
L0_EVENTS_WAIT_TEST(005)
L0_EVENTS_WAIT_TEST(006)
L0_EVENTS_WAIT_TEST(007)
L0_EVENTS_WAIT_TEST(008)
L0_EVENTS_WAIT_TEST(009)
L0_EVENTS_WAIT_TEST(010)
L0_EVENTS_WAIT_TEST(011)
L0_EVENTS_WAIT_TEST(012)
L0_EVENTS_WAIT_TEST(013)
L0_EVENTS_WAIT_TEST(014)
L0_EVENTS_WAIT_TEST(015)
L0_EVENTS_WAIT_TEST(016)
L0_EVENTS_WAIT_TEST(017)
L0_EVENTS_WAIT_TEST(018)
L0_EVENTS_WAIT_TEST(019)
L0_EVENTS_WAIT_TEST(020)
L0_EVENTS_WAIT_TEST(021)
L0_EVENTS_WAIT_TEST(022)
L0_EVENTS_WAIT_TEST(023)
L0_EVENTS_WAIT_TEST(024)
L0_EVENTS_WAIT_TEST(025)
L0_EVENTS_WAIT_TEST(026)
L0_EVENTS_WAIT_TEST(027)
L0_EVENTS_WAIT_TEST(028)
L0_EVENTS_WAIT_TEST(029)
L0_EVENTS_WAIT_TEST(030)
L0_EVENTS_WAIT_TEST(031)
L0_EVENTS_WAIT_TEST(032)
