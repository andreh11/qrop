
import QtQuick 2.3
import QtTest 1.0

TestCase {
    id: testCase
    name: "MyTest"
    when: windowShown

    function create_location_dialog() {
        var import_string = "import QtQuick 2.0; import \"" + Qt.resolvedUrl("../desktop/qml") + "\"; ";
        var item = createTemporaryQmlObject(import_string + "LocationDialog {}", testCase);
        verify(item);
        return item;
    }

    function test_focus() {
        var item = create_location_dialog();

        item.open();
        verify(!item.formAccepted);
        keyClick("a");
        verify(item.name === "a");
        verify(!item.formAccepted);

        keyClick(Qt.Key_Tab);
        keyClick("2");
        verify(item.name === "a");
        verify(item.bedLength === 2);
        verify(!item.formAccepted);

        keyClick(Qt.Key_Tab);
        keyClick("5");
        verify(item.bedWidth === 5);
        verify(!item.formAccepted);

        keyClick(Qt.Key_Tab);
        keyClick("4");
        verify(item.quantity === 4);

        verify(item.formAccepted);
    }

    function test_float_format() {
        var item = create_location_dialog();
        item.open();

        var widthField = item.get_field("bed_width");
        verify(widthField);

        widthField.forceActiveFocus();
        keyClick("5");
        verify(item.bedWidth === 5);

        widthField.clear();
        keyClick("a");
        verify(isNaN(item.bedWidth));

        widthField.clear();
        keyClick("1");
        keyClick(".");
        keyClick("2");
        verify(item.bedWidth === 1.2);

        widthField.clear();
        keyClick("1");
        keyClick(",");
        keyClick("2");
        //Locale is fr for tests. Should accept ","
        verify(item.bedWidth === 1.2);

        widthField.clear();
        widthField.text = "1.2";
        //. converted to , according to locale
        verify(widthField.text === "1,2");
        verify(item.bedWidth === 1.2);

        widthField.clear();
        widthField.text = "1,2";
        verify(widthField.text === "1,2");
        verify(item.bedWidth === 1.2);
    }
}
