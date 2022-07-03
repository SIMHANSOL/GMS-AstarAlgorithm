/// a_path(pos_x, pos_y, t_pos_x, t_pos_y);
// return path;


/* (2017 - 12 - 06)
1. 해당 지점(처음은 시작 지점)을 닫힌 노드에 넣습니다.
2. 해당 지점(처음은 시작 지점)에서부터 주변 지점들을 검색합니다.
3. 각각 주변 지점에서 G, H, F 비용을 연산합니다.
4. 가장 작은 F 비용을 지닌 지점이 다음으로 선택될 지점이 됩니다.
5. 다음으로 선택될 지점의 부모는 해당 지점(처음은 시작 지점)이 됩니다.

    1 ~ 5번 반복....

6. 주변 지점 이동을 통해 목표 지점에 다다르면 반복을 중지합니다.

7. 해당 지점(처음은 목표 지점)의 좌표를 패스에 삽입합니다.
8. 해당 지점(처음은 목표 지점)의 부모를 불러와 7번 내용을 반복합니다.
9. 부모 - 자식 - 부모 - 자식 - 부모를 반복하면 길이 만들어지고 시작 지점에 도착하면 반복을 중지합니다.
10. 삽입된 패스를 반전시키고 완성된 패스를 반환합니다. (목표 지점에서부터 연결했기 때문에 반대이기 때문)
*/

var _start_x = argument0; // pos.
var _start_y = argument1; // pos.
var _end_x = argument2; // pos.
var _end_y = argument3; // pos.

var _debug = true; // 디버깅.

var _path = -1; // 이동 경로를 담을 패스.
if ((_start_x == _end_x && _start_y == _end_y) || grid_table[_end_x, _end_y] == false) {return _path;} // 처음부터 갈 수 없는 곳일 경우 종료.

var _pick_x = _start_x; // 현재 선택된 좌표.
var _pick_y = _start_y; // 현재 선택된 좌표.

var _parent_list = ds_map_create(); // 열린 노드들. (부모 자식, 연결 관계)
var _close_list = ds_list_create(); // 닫힌 노드들.
var _f = ds_priority_create(); // G, H의 총합 비용.
var _g = ds_map_create(); // 시작 지점과의 거리 비용.
var _h = ds_map_create(); // 목적 지점과의 거리 비용.

// 시작하기 전 초기화.
ds_map_add(_g, get_key(_pick_x, _pick_y), 0); // 루프를 시작하기 전에 시작 지점에 G 비용을 추가.

var _i, _j, _serch = true, _found = false;
while(_serch) // 목표 지점까지의 길을 찾을 때까지 루프.
{
    ds_list_add(_close_list, get_key(_pick_x, _pick_y)); // 루프 돌기 전에 시작 지점은 닫는다.

    for(_i = max(0, _pick_x - 1); _i <= min(_pick_x + 1, grid_width - 1); _i++) // 가로.
    {
        for(_j = max(0, _pick_y - 1); _j <= min(_pick_y + 1, grid_height - 1); _j++) // 세로.
        {
            /* 루프 시작.
            O O O / 1 4 7
            O O O / 2 5 8
            O O O / 3 6 9
            */
            
            if ((_i == _pick_x && _j == _pick_y) // 시작 지점 생략.
            || (_i != _pick_x) && (_j != _pick_y)) // 대각 지점 생략. (상 하 좌 우만 확인하게 됨)
            {
                /* 생략 하는 부분.
                X O X
                O X O
                X O X 
                */
                
                continue;
            }
            
            var _walk; // 이동 가능한 타일 확인. (가능은 true)
            var _dis_ij; // 시작점부터의 거리.
            var _closed = ds_list_find_index(_close_list, get_key(_i, _j)) == -1; // 닫힌 노드 리스트 확인하고 리스트 목록에 없으면 true. (목록에 있으면 false)
            
            var _diag = ((_i + _j) % 2 == (_pick_x + _pick_y) % 2); // 대각 확인. (대각이면 true)
            if (_diag == true) // 대각인 경우.
            {
                /* 대각에서부터 선택 지점으로 갈 수 있는지 확인. (상 하 좌 우) [그래야 지점에서부터 대각으로 이동 가능]
                X: 대각 부분.
                T: 대각에서 추가로 확인하는 부분.
                X T O   O O O   O T X
                T O O   T O O   O O T
                O O O   X T O   O O O
                */
                
                _walk = grid_table[_i, _j] && grid_table[_pick_x, _j] && grid_table[_i, _pick_y];
                _dis_ij = 1.414; // 직선이 1임을 가정하면 대각선은 피타고라스 정리에 의해 1.4이다. [(a*a + b*b) = c*c]
            }
            else // 대각이 아닌 경우.
            {
                _walk = grid_table[_i, _j];
                _dis_ij = 1;
            }
            
            if (_closed && _walk) // 닫힌 노드가 아니고, 이동할 수 있는 곳이면.
            {
                var _temp_g = ds_map_find_value(_g, get_key(_pick_x, _pick_y)) + _dis_ij; // 선택된 지점의 G 비용과 루프 돌고 있는 지점의 G 비용을 더해서 합계 G 비용을 루프 지점에 대입.
                var _temp_h = abs(_i - _end_x) + abs(_j - _end_y); // 루프 돌고 있는 지점에서 목적 지점까지의 H 비용.
                var _temp_f = _temp_g + _temp_h; // 합계 비용.
                
                if (ds_map_exists(_g, get_key(_i, _j)) == true) // 전에 계산한 G 비용이 존재하는지 확인.
                {
                    if (ds_map_find_value(_g, get_key(_i, _j)) > _temp_g) // 전에 계산한 G 비용보다 지금 계산한 G 비용이 더 작을 경우. (더 나은 길을 찾기 위해)
                    {
                        ds_map_replace(_g, get_key(_i, _j), _temp_g);
                        ds_map_replace(_h, get_key(_i, _j), _temp_h);
                        ds_map_replace(_parent_list, get_key(_i, _j), get_key(_pick_x, _pick_y));
                        ds_priority_change_priority(_f, get_key(_i, _j), _temp_f);
                    }
                }
                else // 이번이 처음 G 비용 계산이라면.
                {
                    ds_map_add(_g, get_key(_i, _j), _temp_g); // 계산한 G 비용을 루프 돌고 있는 지점에 추가.
                    ds_map_add(_h, get_key(_i, _j), _temp_h); // 계산한 H 비용을 루프 돌고 있는 지점에 추가.
                    ds_map_add(_parent_list, get_key(_i, _j), get_key(_pick_x, _pick_y)); // 루프 돌고 있는 지점에게 선택된 지점을 부모로 지정.
                    ds_priority_add(_f, get_key(_i, _j), _temp_f); // 루프 돌고 있는 지점에 F 비용을 추가.
                    
                    if (_debug == true)
                    {
                        ds_priority_add(debug_f, get_key(_i, _j), _temp_f);
                    }
                }
                
                if (_debug == true)
                {
                    var _de_g = 0, _de_h = 0;
                    _de_g = ds_map_find_value(_g, get_key(_i, _j));
                    _de_h = ds_map_find_value(_h, get_key(_i, _j));
                    var _de_f = _de_g + _de_h;
                    
                    show_debug_message("x:" + string(_i) +" / y:" + string(_j) +
                    " g:" + string(_de_g) + " h:" + string(_de_h) + " f:" + string(_de_f) +
                    " open:" + string(_closed));
                }
            }
        }
    }
    
    // 최대 8개의 주변 노드들의 연산을 마치고 나서 F 비용을 따라 이동.
    if (ds_priority_empty(_f) == false) // F 비용 목록이 비어있지 않다면 가장 작은 F 비용을 찾아 대입.
    {
        _min = ds_priority_delete_min(_f); // 가장 작은 F 비용의 지점을 _min에 기록하고 목록에서 삭제한다.
        _pick_x = get_key_x(_min); // 가장 작은 F 비용을 가진 지점의 X를 대입. 
        _pick_y = get_key_y(_min); // 가장 작은 F 비용을 가진 지점의 Y를 대입.
        
        if (_debug == true)
        {
            show_debug_message("move:" + string(_pick_x) + " / " + string(_pick_y));
        }
    }
    else // 지점을 찾을 수 없다면 종료.
    {
        _serch = false;
        _found = false;
    }
    
    // 선택된 지점이 목표 지점까지 도착했을 경우.
    if(_pick_x == _end_x && _pick_y == _end_y)
    {
        _serch = false;
        _found = true;
    }
} // 길을 찾지 못하거나, 목표 지점에 도착할 때까지 무한 반복.

if (_found == true) // 길이 연결되어 있다면.
{
    _path = path_add();
    var _node = get_key(_end_x, _end_y); // 목표 지점에서부터 실행.
    while(_node != get_key(_start_x, _start_y))
    {
        path_add_point(_path, get_key_x(_node) * grid_size_x, get_key_y(_node) * grid_size_y, 100); // 해당 지점을 패스에 삽입.
        _node = ds_map_find_value(_parent_list, _node); // 해당 지점의 부모를 가지고 옴.
    } // 부모가 시작 지점이 될 때까지 반복. (이렇게 자식, 부모를 가지고 반복하면 결국 목표 지점에서부터 시작 지점까지의 길이 만들어짐)
    
    path_add_point(_path, _start_x * grid_size_x, _start_y * grid_size_y, 100); // 마지막으로 시작 지점을 넣어줌.
    path_reverse(_path); // 목표 지점에서 시작 지점까지 반대로 연결했음으로 다시 반대로 변경. ([목표 - 시작] - [시작 - 목표])
    path_set_closed(_path, false); // 패스를 닫음. (패스 특성상 목표 지점으로 갔다가 시작 지점으로 되돌아오는 것 방지)
}

ds_map_destroy(_parent_list);
ds_list_destroy(_close_list);
ds_priority_destroy(_f);
ds_map_destroy(_g);
ds_map_destroy(_h);

return _path; // 패스 반환.
