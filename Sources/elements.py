# Libs
import machine
import utime


from screen import Screen_element
import consts as const


class Clock(Screen_element):
    def __init__(self, ntw, sc, max_time_check):
        Screen_element.__init__(self, ntw, sc, max_time_check)
        self.url = const.CLOCK_URL
        self.tm = None

    def get(self):
        print("Getting time")
        time_data = self.ntw.request("GET", self.url)
        print("Time response =", time_data)
        if time_data is not None:
            unix_timestamp = (
                int(time_data["unixtime"]) - 946684800 + 3600 * const.CLOCK_UTC_OFFSET
            )
            is_set = True
        else:
            unix_timestamp = 0
            is_set = False
        self.tm = utime.localtime(unix_timestamp)
        machine.RTC().datetime(self.tm[0:3] + (0,) + self.tm[3:6] + (0,))
        print("machine time set")
        return is_set


class Weather(Screen_element):
    def __init__(self, ntw, sc, max_time_check):
        Screen_element.__init__(self, ntw, sc, max_time_check)
        self.current_temperature = None
        self.complete_url = (
            const.WEATHER_URL
            + "appid="
            + const.WEATHER_API_KEY
            + "&q="
            + const.WEATHER_CITY
        )
        # https://www.weatherbit.io/api/codes
        self.id_options = {
            2: "thunder",
            3: "rain",
            5: "rain",
            6: "snow",
            7: "mist",
            8: "clouds",
            9: "rain",
        }

    def get(self):
        print("Getting weather")
        WEATHER_data = self.ntw.request("GET", self.complete_url)
        print("Weather response =", WEATHER_data)

        if WEATHER_data is not None and WEATHER_data["cod"] != "404":
            self.WEATHER_description = WEATHER_data["weather"][0]["description"]
            self.WEATHER_id = WEATHER_data["weather"][0]["id"]
            self.current_temperature = round(WEATHER_data["main"]["temp"] - 273.15)
            self.current_pressure = WEATHER_data["main"]["pressure"]
            self.current_humidity = WEATHER_data["main"]["humidity"]

            if self.WEATHER_id == 800:
                self.pixel_art = "clear"
            elif int(self.WEATHER_id / 100) in self.id_options:
                self.pixel_art = self.id_options[int(self.WEATHER_id / 100)]
            else:
                self.pixel_art = "cross"
            result = True
        else:
            print("City Not Found")
            self.WEATHER_description = "None"
            self.WEATHER_id = 0
            self.current_temperature = 0
            self.current_pressure = 0
            self.current_humidity = 0
            self.pixel_art = "cross"
            result = False

        temp_str = str(self.current_temperature)
        y = 7
        self.sc.set_memory(
            name="WEATHER_art", elem_type="pixel", content=(0, y, self.pixel_art)
        )
        self.sc.set_memory(
            name="WEATHER_temp", elem_type="str", content=(1, y, temp_str)
        )
        self.sc.set_memory(
            name="WEATHER_temp_type",
            elem_type="pixel",
            content=(1 + len(temp_str), y, "celcius"),
        )
        self.sc.set_memory(
            name="WEATHER_humidity",
            elem_type="str",
            content=(2 + len(temp_str), y, str(self.current_humidity) + "%"),
        )
        return result
